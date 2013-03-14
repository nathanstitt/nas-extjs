
namespace :build do

    desc "Compile all coffeescript files in public app directory"
    task :coffee do
        `find ./public/app -name '*.coffee' ! \\( -name '.*' \\) -print0 | xargs -n20 -0 coffee -c `
    end

end
