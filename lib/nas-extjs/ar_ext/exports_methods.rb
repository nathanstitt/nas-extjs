require 'active_support/concern'

module NasExtjs::ArExt

    module ExportsMethods
        extend ActiveSupport::Concern

        included do
            class_attribute :exported_optional_methods
            class_attribute :exported_mandatory_methods
            class_attribute :exported_delegated_fields
        end

        module ClassMethods
            def export_methods( *method_names )
                method_names.flatten!
                options = method_names.extract_options!
                storage = if options[:optional]
                              ( self.exported_optional_methods ||= [] )
                          else
                              ( self.exported_mandatory_methods ||= [] )
                          end
                storage.concat method_names.map{|m|m.to_sym}
            end

            def delegate_and_export( *names )
                opts = names.extract_options!
                names.each do | name |
                    target,field = name.to_s.split(/_(?=[^_]+(?: |$))| /)
                    delegate_and_export_field( target, field, opts )
                end
            end

            def delegate_and_export_field( target, field, export_opts={} )

                opts = {}
                opts[:to]=target
                opts[:prefix]=target
                opts[:allow_nil]=true

                delegate( field, opts )
                method_name = "#{target}_#{field}"
                if export_opts[:optional] == false
                    self.export_methods method_name, export_opts
                else
                    self.exported_delegated_fields ||= []
                    self.exported_delegated_fields << { :association => target, :method_name => method_name }
                end
            end

            def api_allowed_method?( method )
                ( self.exported_optional_methods && self.exported_optional_methods.include?( method.to_sym ) ) || 
                    ( self.exported_mandatory_methods && self.exported_mandatory_methods.include?( method.to_sym ) )
            end

        end


    end

end

ActiveRecord::Base.send :include, NasExtjs::ArExt::ExportsMethods
