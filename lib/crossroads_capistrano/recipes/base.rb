#
# These base defaults are always loaded unless otherwise specified.
#

# Recipes
# ---------------------------------------------------------
load File.join(File.dirname(__FILE__), "helper_methods.rb")
load File.join(File.dirname(__FILE__), "config.rb")


# Settings
# ---------------------------------------------------------
set :default_stage,  "preview"
set :rails_env,      "production"

set :scm,            :git
set :branch,         "master"
set :deploy_via,     :remote_cache
set :keep_releases,  3

set :bundle_without, [:cucumber, :development, :test]

set :httpd_user,     "apache"
set :httpd_group,    "apache"
set :http_port,      "80"
set :https_port,     "443"

default_run_options[:pty] = true

def needs_netrc?;   repository.include?("svn.globalhand.org"); end
def needs_ssh_key?; repository.include?("github.com"); end


# Hooks
# ---------------------------------------------------------
before "deploy:symlink",  "deploy:symlink_config"
after  "deploy:restart",  "deploy:cleanup"


# Misc. Tasks
# ---------------------------------------------------------
namespace :deploy do
  desc "Symlink Shared config files into release path."
  task :symlink_config do
    run "ln -sf #{shared_path}/config/*.yml #{release_path}/config/"
  end
  desc "Check for project dependencies"
  task :check_dependencies, :roles => :db, :only => { :primary => true } do
    sudo "cd #{current_path} && RAILS_ENV=production rake check_dependencies"
  end
end


# Capistrano Fixes
# ---------------------------------------------------------
set(:current_release) { File.join(releases_path, releases.last.to_s) }
