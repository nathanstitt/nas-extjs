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
            if self.exported_methods
                options[:methods] = ( options[:methods] + self.exported_methods ).uniq
            end
            ex = ( options[ :except ] ||= [] )
            ex << 'tenant_id' unless ex.include?('tenant_id')
            options[ :except ] = ex
            super(options)
        end

    end

end


ActiveRecord::Base.send :include, NasExtjs::ArExt::ApiSerializeableHash
