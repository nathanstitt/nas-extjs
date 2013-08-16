require 'active_support/concern'

module NasExtjs::ArExt

    module ImmutableModel
        extend ActiveSupport::Concern

        module ClassMethods
            def is_immutable(options = {})

                options[:except] = [*options[:except]].map{|name| name.to_s } # make sure except is present and an array

                before_destroy do
                    raise ActiveRecord::ReadOnlyRecord.new( "Can not destroy #{self.class.model_name}, only create is allowed" )
                end

                before_update do
                    unless ( changes.keys - options[:except] ).blank?
                        raise ActiveRecord::ReadOnlyRecord.new(  "Can not update, only create #{self.class.model_name}" )
                    end
                end

            end

        end

    end
end

ActiveRecord::Base.send :include, NasExtjs::ArExt::ImmutableModel
