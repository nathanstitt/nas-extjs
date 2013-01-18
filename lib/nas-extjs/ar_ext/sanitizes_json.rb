require 'active_support/concern'

module NasExtjs::ArExt

    module SanitizesJson
        extend ActiveSupport::Concern

        included do
            class_attribute :blacklisted_json_attributes
            self.blacklisted_json_attributes = [ 'updated_by_id','created_by_id','updated_at','created_at', 'visible_id' ]
        end

        module ClassMethods

            def blacklist_json_attributes( *attrs )
                self.blacklisted_json_attributes += attrs.map{|attr| attr.to_s }
                self.blacklisted_json_attributes.uniq!
            end

            def api_sanitize_json( json )
                json.stringify_keys.each_with_object( Hash.new ) do | kv,ret |
                    (key,val)=kv


                    if (
                        ! _api_is_blacklisted?( kv.first ) && (
                                                           ( self.attribute_names && self.attribute_names.include?(key) ) ||
                                                           ( self.allowed_attributes && self.allowed_attributes.include?(key) ) ||
                                                           ( key == '_destroy')
                                                           ) )
                        ret[key] = val
                    elsif _api_is_exported?( key ) && _api_accepts_nested?( key )

                        klass = self.reflections[ key.sub('_attributes','').to_sym ].class_name.constantize
                        # only Hash, Array & nil is valid for nesting attributes
                        next if val.nil?

                        ret[key] = if val.is_a?( Hash ) 
                                       klass.api_sanitize_json( val )
                                   else
                                       val.map{ | data | klass.api_sanitize_json( data ) }
                                   end
                    end

                end

            end

            def _api_is_blacklisted?(name)
                blacklisted_json_attributes.include?( name )
            end

            def _api_is_exported?( name )
                self.exported_associations && self.exported_associations.find{|n| n.to_s + '_attributes' == name }
            end

            def _api_accepts_nested?(name)
                self.nested_attributes_options? && self.nested_attributes_options[ name.sub('_attributes','').to_sym ]
            end


        end
    end

end


ActiveRecord::Base.send :include, NasExtjs::ArExt::SanitizesJson
