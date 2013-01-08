require 'active_support/concern'

module NasExtjs::ArExt

    module ExportsMethods
        extend ActiveSupport::Concern

        included do
            class_attribute :exported_optional_methods
            class_attribute :exported_methods
        end

        module ClassMethods
            def exports_methods( *method_names )
                method_names.flatten!
                options = method_names.extract_options!
                storage = if options[:optional]
                              ( self.exported_optional_methods ||= [] )
                          else
                              ( self.exported_methods ||= [] )
                          end
                storage.concat method_names.map{|m|m.to_sym}
            end

            def delegate_and_export( *names )
                opts = names.last.is_a?(Hash) ? names.pop : {}
                names.each do | name |
                    target,field = name.to_s.split(/_(?=[^_]+(?: |$))| /)
                    delegate_and_export_field( target, field )
                end
            end

            def delegate_and_export_field( target, field, opts={} )
                self.exported_methods ||= []

                opts[:to]=target
                opts[:prefix]=target
                opts[:allow_nil]=true
                default_scope includes( target )
                delegate( field, opts )

                self.exports_methods "#{target}_#{field}", opts
            end

            def api_allowed_method?( method )
                self.exported_optional_methods && self.exported_optional_methods.include?( method.to_sym )
            end

        end


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

ActiveRecord::Base.send :include, NasExtjs::ArExt::ExportsMethods
