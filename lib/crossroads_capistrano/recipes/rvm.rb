require 'rvm/capistrano'

namespace :rvm do

  desc "Install rvm"
  task :install, :roles => :web do
    install_deps
    run "if ! [ -e #{rvm_bin_path}/rvm ]; then #{sudo} bash -c \"curl -s https://rvm.beginrescueend.com/install/rvm | bash\"; fi", :shell => 'sh'
    run "if ! (#{rvm_bin_path}/rvm list | grep #{rvm_ruby_string}); then #{sudo} #{rvm_bin_path}/rvm install #{rvm_ruby_string}; fi", :shell => 'sh'
  end

  task :install_deps, :roles => :web do
    yum.install( {:base => %w(curl git gcc-c++ patch readline readline-devel zlib zlib-devel libyaml-devel libffi-devel openssl-devel make bzip2)}, :stable, :shell => 'sh' )
  end

  desc "Trust the application rvmrc file that is deployed"
  task :trust_me do
    run "rvm rvmrc trust #{current_path}"
    run "if [ -d #{release_path} ]; then rvm rvmrc trust #{release_path}; fi"
  end

end

before "stack", "rvm:install"
before "deploy:restart", "rvm:trust_me"
