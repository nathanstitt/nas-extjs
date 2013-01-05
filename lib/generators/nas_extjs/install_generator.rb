require 'rails/generators'

module NasExtjs

    class InstallGenerator < Rails::Generators::Base

        desc "Copy files to extjs project"

        
        source_root File.expand_path( '../templates', __FILE__ )

        def copy_extjs_files
            %w{ lib ux }.each do | dir |
                directory "public/app/#{dir}"
            end
            %w{ model store }.each do | dir |
                directory "public/app/#{dir}"
                directory "public/app/#{dir}/mixins"
            end
            directory "lib/tasks"

        end

        def build_coffee_files
            rake("build:coffee")
        end
    end



end
