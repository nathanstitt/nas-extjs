module NasExtjs

    class Controller < ActionController::Base

        around_filter   :capture_exceptions
        before_filter   :api_strip_record_id, :only=>[:create]
        class_attribute :model_class
        class_attribute :limit_query_results_to
        class_attribute :nested_attribute

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
                query = query.where({ :id => params[:id] }).first!
            end
            if nested_attribute && params[nested_attribute]
                query = query.where( Hash[ nested_attribute, params[nested_attribute] ] )
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
            rec.destroy
            render json_reply( rec, api_reply_options.merge( { success: rec.errors.empty?  } ) )
        end

        protected

        def capture_exceptions
            yield
        rescue ActiveRecord::RecordInvalid=>e
            render json_reply( e.record, false )
        rescue ActiveRecord::RecordNotFound=>e
            render :json => {
                :success => false,
                :message => model_class.model_name.human + " or one of it's related records was not found"
            }, :status=>:not_found
        end

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

        def query_limited_to
            limit = limit_query_results_to || 250 # should be enough for everybody, amirite?
            params[:limit] ? [ params[:limit].to_i, limit ].min : limit
        end


        def add_to_query( query, opts={} )
            if opts[:limits]
                query = query.limit( query_limited_to )
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
                    query = add_sort_to_query( query, fld.gsub(/[^\w|^\.]/,''), ( 'asc' == dir.downcase ) )
                end
            end
            query
        end

        def add_sort_to_query( query, field, asc )
            query.order( field + ' ' + ( asc ? 'ASC' : 'DESC' ) )
        end

        def api_query( klass, query = klass.all )
            if nested_attribute && params[nested_attribute]
                query = query.where( Hash[ nested_attribute, params[nested_attribute] ] )
            end
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

                field = if k.include?('.')
                            ( table_name, field_name ) = k.split('.')
                            table = if klass.has_exported_join_table?( table_name )
                                        Arel::Table.new( table_name )
                                    else
                                        stmt = stmt.joins(table_name.to_sym)
                                        table_name.singularize.camelize.constantize.arel_table
                                    end
                            table[ field_name ]
                        else
                            klass.arel_table[k]
                        end

                condition = if v.is_a?( Hash ) && v.has_key?('value')
                                api_op_string_to_arel_predicate( field, v['op'], v['value'] )
                            else
                                api_op_string_to_arel_predicate( field, nil, v )
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
            when ( op=='in' && value=~/.*:.*/ ) then field.in( Range.new( *value.split(':') ) )
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

        def self.set_nested_attribute( attr )
            self.nested_attribute = attr
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
                action = if obj.new_record? || obj.id_changed?
                             "Create"
                         elsif obj.destroyed?
                             "Destroy"
                         else
                             "Update"
                         end
                action + ' ' + obj.class.model_name.human
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
