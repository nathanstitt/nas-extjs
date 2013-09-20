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
                storage = if false == options[:optional]
                              ( self.exported_mandatory_methods ||= [] )
                          else
                              ( self.exported_optional_methods ||= [] )
                          end
                storage.concat method_names.map{|m|m.to_s}
            end

            def delegate_and_export( *names )
                opts = names.extract_options!
                names.each do | name |
                    target,field = name.to_s.split(/_(?=[^_]+(?: |$))| /)
                    delegate_and_export_field( target, field, opts )
                end
            end

            def delegate_and_export_field( target, field, export_opts={} )
                file, line = caller.first.split(':', 2)
                method_name = "#{target}_#{field}"
                module_eval(<<-EOS,file,line.to_i)
                    def #{method_name}
                       if value = read_attribute( "#{method_name}" )
                            return value
                       elsif !#{target}.nil? || nil.respond_to?(:#{field})
                            return #{target}.#{field}
                       else
                            return nil
                       end
                    end
                EOS

                if false == export_opts[:optional]
                    self.export_methods method_name, export_opts
                else
                    self.exported_delegated_fields ||= []
                    self.exported_delegated_fields << { 'association' => target, 'method_name' => method_name }
                end
            end

            def api_allowed_method?( method )
                !! (
                    ( self.exported_optional_methods && self.exported_optional_methods.include?( method.to_s ) ) ||
                    ( self.exported_mandatory_methods && self.exported_mandatory_methods.include?( method.to_s ) )
                    )
            end

        end


    end

end

ActiveRecord::Base.send :include, NasExtjs::ArExt::ExportsMethods
