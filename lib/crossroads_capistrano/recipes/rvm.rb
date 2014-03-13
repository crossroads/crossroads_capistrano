require 'rvm/capistrano'

set :rvm_autolibs_flag, '4' # auto installation of libraries, see http://rvm.io/rvm/autolibs

before 'deploy:setup', 'rvm:install_rvm'   # install RVM
before 'deploy:setup', 'rvm:install_ruby'  # install Ruby
