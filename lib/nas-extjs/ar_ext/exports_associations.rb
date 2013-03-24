require 'active_support/concern'

module NasExtjs::ArExt

    module ExportsAssociations
        extend ActiveSupport::Concern

        included do
            class_attribute :exported_associations
            class_attribute :allowed_attributes
        end

        module ClassMethods

            def export_associations( *associations )
                self.exported_associations ||= []
                associations.flatten!
                options = associations.extract_options!
                writable  =  true == options.delete(:writable)
                mandatory = false == options.delete(:optional)
                associations.each do |m|
                    self.exported_associations << m.to_s
                    accepts_nested_attributes_for( m, options )  if writable
                    self.export_methods( m,{ :optional=>false }) if mandatory
                end
            end

            def set_other_mass_attributes_allowed( *attrs )
                self.allowed_attributes ||= []
                attrs.each do | attr |
                    self.allowed_attributes << attr.to_s
                end
            end


            def api_allowed_association?( association )
                self.exported_associations && self.exported_associations.include?( association.to_s )
            end

       end

    end

end


ActiveRecord::Base.send :include, NasExtjs::ArExt::ExportsAssociations
