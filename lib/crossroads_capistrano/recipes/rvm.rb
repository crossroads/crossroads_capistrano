require 'rvm/capistrano'

namespace :rvm do

  desc "Install rvm"
  task :install, :roles => :web do
    install_deps
    sudo "if ! (which rvm); then bash < <( curl http://rvm.beginrescueend.com/releases/rvm-install-head ); fi", :shell => 'sh'
    sudo "if ! (rvm list | grep #{rvm_ruby_string}); then rvm install #{rvm_ruby_string}; fi", :shell => 'sh'
  end

  task :install_deps, :roles => :web do
    yum.install( {:base => %w(curl git gcc-c++ patch readline readline-devel zlib zlib-devel libyaml-devel libffi-devel openssl-devel make bzip2)}, :stable, :shell => 'sh' )
  end

end

before "stack", "rvm:install"

