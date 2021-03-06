#
# These base defaults are always loaded unless otherwise specified.
#

# Recipes
# ---------------------------------------------------------
load File.join(File.dirname(__FILE__), "core_ext.rb")
load File.join(File.dirname(__FILE__), "helper_methods.rb")
load File.join(File.dirname(__FILE__), "config.rb")

# Settings
# ---------------------------------------------------------
set :default_stage,  "staging"
set :rails_env,      "production"

set :scm,            :git
set :branch,         "master"
set :deploy_via,     :remote_cache
set :keep_releases,  3

set :bundle_without, [:cucumber, :development, :test]
# Prevent US-ASCII issues when gemspecs contain UTF-8 characters (author names, etc.)
set :bundle_cmd, "LANG='en_US.UTF-8' LC_ALL='en_US.UTF-8' bundle"

set :httpd_user,     "apache"
set :httpd_group,    "apache"
set :http_port,      "80"
set :https_port,     "443"

default_run_options[:pty] = true

def needs_netrc?;   repository.include?("code.crossroads.org.hk"); end
def needs_ssh_key?; repository.include?("github.com"); end


# Hooks
# ---------------------------------------------------------
after "deploy:update_code",  "deploy:symlink_config"
after  "deploy:restart",  "deploy:cleanup"

# Deployment tasks that need an after hook to notify hoptoad/newrelic/etc.
NotificationTasks = ["deploy", "deploy:migrations", "deploy:cold", "deploy:rollback"]


# Misc. Tasks
# ---------------------------------------------------------
namespace :deploy do
  desc "Symlink Shared config files into release path."
  task :symlink_config do
    run "ln -sf #{shared_path}/config/*.yml #{release_path}/config/"
  end
  desc "Check for project dependencies"
  task :check_dependencies, :roles => :db, :only => { :primary => true } do
    sudo "cd #{current_path} && bundle exec rake check_dependencies RAILS_ENV=#{rails_env}"
  end
  desc "Remove cached-copy (when switching to a new repository, etc.)"
  task :remove_cached_copy, :roles => :db, :only => { :primary => true } do
    sudo "rm -rf #{shared_path}/cached-copy"
  end
end


# Capistrano Fixes
# ---------------------------------------------------------
set(:current_release) { File.join(releases_path, releases.last.to_s) }

