require 'rvm/capistrano'

before 'deploy:setup', 'rvm:install_rvm'   # install RVM
#  This must come before the 'rvm:install_ruby' task is called.
set :rvm_install_pkgs, %w(curl git gcc-c++ patch readline readline-devel zlib zlib-devel libyaml-devel libffi-devel openssl-devel make bzip2)
before 'deploy:setup', 'rvm:install_ruby'  # install Ruby and create gemset, or:
