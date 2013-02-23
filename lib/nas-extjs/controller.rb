module NasExtjs

    class Controller < ActionController::Base

        before_filter   :api_strip_record_id, :only=>[:create]
        class_attribute :model_class

        def index
            query = api_query( model_class )
            opts  = api_reply_options
            if params[:limit] && params[:start]
                opts[:total_count] = query.dup.count
            end
            query = add_to_query( query, :limits=>true, :includes=>true, :sort=>true )
            check_authorization( :index, query )
            render json_reply( query, opts )
        end

        def show
            query = api_query( model_class )
            opts  = api_reply_options
            if params[:id]
                query = query.where({ :id => params[:id] })
            end
            check_authorization( :show, query )
            render json_reply( query, opts )
        end

        def create
            rec = model_class.new( model_class.api_sanitize_json( params[:data] ) )
            check_authorization( :create, rec )
            render json_reply( rec, api_reply_options.merge( { success: rec.save } ) )
        end


        def update
            rec = get_record_for_update
            check_authorization( :update, rec )
            render_update( rec )
        end

        def destroy
            rec = get_record_for_update
            check_authorization( :destroy, rec )
            render json_reply( rec, api_reply_options.merge( { success: rec.destroy } ) )
        end

        protected


        def check_authorization( method, rec )
            # NOOP, intended to be override by projects that use cancan
        end

        def api_find_options(opts={})
            if params[:include]
                inc = params[:include]
                opts[:include] = inc if inc && ! inc.empty?
            end
            opts
        end

        def add_to_query( query, opts={} )
            if opts[:limits]
                query = query.limit( params[:limit].to_i ) if params[:limit]
                query = query.offset( params[:start].to_i ) if params[:start]
            end
            if opts[:includes] && ! params[:include].blank?
                good_params = [ *params[:include] ].select do |inc| 
                    if inc.is_a?(Hash)
                        inc.reject!{| name,val | ! model_class.api_allowed_association?( name )  }
                        true
                    else
                        model_class.api_allowed_association?(inc) 
                    end
                end
                query = query.includes( good_params )
            end
            if opts[:sort]  && ! params[:sort].blank?
                params[:sort].each do | fld, dir |
                    query = query.order( "#{fld} #{dir}" )
                end
            end
            query
        end

        def api_query( klass, query = klass.scoped )

            if params[:scope]
                params[:scope].each do | name, arg |
                    if klass.has_exported_scope?( name )
                        args = [name]
                        args.push( arg ) unless arg.blank?
                        query = query.send( *args )
                    end
                end
            end
            if params[:query].is_a?(Hash)
                query = api_add_query( klass, query, params[:query])
            end

            query
        end

        def api_add_query( klass, stmt, query )
            query.each do | k,v |
                if k =~ /\./
                    ( table, field ) = k.split('.')
                    k = table.singularize.camelize.constantize.arel_table[field]
                    stmt = stmt.joins(table.to_sym)
                else
                    k = klass.arel_table[k]
                end
                condition = if v.is_a?( Hash ) && v.has_key?('value')
                                api_op_string_to_arel_predicate( k, v['op'], v['value'] )
                            else
                                api_op_string_to_arel_predicate( k, nil, v )
                            end
                stmt = stmt.where( condition )
            end
            stmt
        end

        # complete list: https://github.com/rails/arel/blob/master/lib/arel/predications.rb
        def api_op_string_to_arel_predicate( field, op, value )
            case op
            when 'eq'   then field.eq(value)
            when 'ne'   then field.not_eq(value)
            when 'lt'   then field.lt(value)
            when 'gt'   then field.gt(value)
            when 'like' then field.matches( value )
            else
                value =~ /%/ ? field.matches( value ) : field.eq( value )
            end
        end

        def api_reply_options( opts = {} )
            inc = {}
            if params[:include]
                params[:include].each do |name|
                    if name.is_a?( Hash )
                        name.each do |k,v|
                            if model_class.api_allowed_association?(k)
                                inc[ k.to_sym ] = { :include=> v.map{ | vn | vn.to_sym } }
                            end
                        end
                    elsif name.is_a?( Array )
                        name.each do |k|
                            inc[ k.to_sym ] = {} if  model_class.api_allowed_association?(k)
                        end
                    else
                        inc[ name.to_sym ] = {} if  model_class.api_allowed_association?(name)
                    end
                end
            end
            opts[:include] = inc

            opts[:methods] = ( params[:optfields] || opts[:optfields] || [] ).select{|f| model_class.api_allowed_method?(f) }

            opts
        end

        def self.set_model_class( sym )
            self.model_class = sym.to_s.camelize.constantize
        end

        def render_update( rec )
            render json_reply( rec, api_reply_options.merge( { success: rec.save } ) )
        end

        def get_record_for_update
            rec = model_class.find( params[:id], api_find_options )
            rec.assign_attributes model_class.api_sanitize_json( params[:data] )
            rec
        end

        def api_strip_record_id
            params[:data].delete(:id) if params.has_key?(:data)
        end

        # json methods

        def json_reply( obj, opts = {} )

            opts = { :success=>opts } unless opts.is_a?(Hash)
            opts.to_options!
            success = opts[:success].nil? ? true : opts[:success]
            ret = {
                :success => success,
                :message => json_status_str(obj,success),
                :data => success ? ( opts.has_key?(:json) ? opts[:json] : obj ) : obj.changes.inject({}){|h,(k,v)| h[k]=v.first; h }
            }
            if opts.has_key? :total_count
                ret[:total]=opts[:total_count]
                opts.delete( :total_count )
            end
            if ! success
                ret[:errors] = errs = {}
                obj.errors.each{ | attr, msgs |
                    errs.store( attr,  msgs)
                }
            end
            return { :json=> ret.as_json(opts) }
        end

        def json_type_str( obj )
            if obj.kind_of?( ActiveRecord::Base )
                if obj.new_record?
                    "Create " + obj.class.model_name.human;
                elsif obj.destroyed?
                    "Destroy " + obj.class.model_name.human + ' (' + obj.id.to_s + ')';
                else
                    "Update " + obj.class.model_name.human +  ' (' + obj.id.to_s + ')';
                end
            else
                "Listing"
            end
        end

        def json_status_str(obj,success)
            if success
                return json_type_str(obj) + " succeeded"
            elsif obj
                return json_type_str(obj) + " failed: " + obj.errors.full_messages.join("; ")
            else
                return "Record not found"
            end
        end

    end

end # NasExtjs

