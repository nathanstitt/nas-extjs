require 'rails/generators'

module NasExtjs

    class InstallGenerator < Rails::Generators::Base

        desc "Copy files to extjs project"

        
        source_root File.expand_path( '../templates', __FILE__ )


        def create_util_files
            directory 'foo'
        end
    end



end
