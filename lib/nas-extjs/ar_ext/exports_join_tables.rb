require 'active_support/concern'

module NasExtjs::ArExt

    module ExportsJoinTables
        extend ActiveSupport::Concern

        included do
            class_attribute :exported_join_tables

        end

        module ClassMethods
            def export_join_tables( *tables )
                self.exported_join_tables ||= []
                self.exported_join_tables += tables
            end

            def has_exported_join_table?( name )
                self.exported_join_tables && self.exported_join_tables.include?( name.to_sym )
            end

        end
    end

end


ActiveRecord::Base.send :include, NasExtjs::ArExt::ExportsJoinTables
