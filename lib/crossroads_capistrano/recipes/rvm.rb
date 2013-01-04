require 'rvm/capistrano'

namespace :rvm do

  desc "Trust the application rvmrc file that is deployed"
  task :trust_me do
    run "rvm rvmrc trust #{current_path}"
    run "if [ -d #{release_path} ]; then rvm rvmrc trust #{release_path}; fi"
  end

end

before "deploy:restart", "rvm:trust_me"
before 'deploy:setup', 'rvm:install_rvm'   # install RVM
set :rvm_install_pkgs, %w(curl git gcc-c++ patch readline readline-devel zlib zlib-devel libyaml-devel libffi-devel openssl-devel make bzip2) #  This must come before the 'rvm:install_ruby' task is called.
before 'deploy:setup', 'rvm:install_ruby'  # install Ruby and create gemset, or:
