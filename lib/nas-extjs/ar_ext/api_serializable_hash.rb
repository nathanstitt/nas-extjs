require 'active_support/concern'


module NasExtjs::ArExt

    module ApiSerializeableHash

        def serializable_hash( options={} )
            options.nil? ? options = {} : options.symbolize_keys!
            if  options[:methods]
                options[:methods] = options[:methods].reject{ | m | m.nil? }
            else
                options[:methods] = []
            end
            if self.exported_mandatory_methods
                options[:methods] += self.exported_mandatory_methods
            end
            if self.exported_delegated_fields
                loaded = self.exported_delegated_fields.select{ | export | self.association(export['association'].to_sym ).loaded? }
                options[:methods] += loaded.map{ |export| export['method_name'] }
            end
            options[:methods].map!(&:to_s).uniq!
            ex = ( options[ :except ] ||= [] )
            ex << 'tenant_id' unless ex.include?('tenant_id')
            options[ :except ] = ex
            super(options)
        end

    end

end


ActiveRecord::Base.send :include, NasExtjs::ArExt::ApiSerializeableHash
