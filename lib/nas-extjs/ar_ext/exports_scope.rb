require 'active_support/concern'

module NasExtjs::ArExt

    module ExportsScope

        extend ActiveSupport::Concern

        included do
            class_attribute :exported_scopes
        end

        module ClassMethods

            def export_scope( name, *args )
                self.exported_scopes ||= Hash.new
                self.exported_scopes[ name.to_sym ] = scope name, *args
            end

            def has_exported_scope?( name )
                self.exported_scopes && self.exported_scopes.has_key?(name.to_sym)
            end

      end

    end


end


ActiveRecord::Base.send :include, NasExtjs::ArExt::ExportsScope
