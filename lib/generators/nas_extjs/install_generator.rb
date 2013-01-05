require 'rails/generators'

module NasExtjs

    class InstallGenerator < Rails::Generators::Base

        desc "Copy files to extjs project"

        
        source_root File.expand_path( '../templates', __FILE__ )


        def create_util_files
            puts 'Makeing Direcory '
            directory 'public/app/lib'
        end
    end



end
