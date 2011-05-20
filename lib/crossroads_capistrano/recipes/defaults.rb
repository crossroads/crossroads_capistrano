# These default recipes are always loaded unless otherwise specified

# Default recipes
# ---------------------------------------------------------
load File.join(File.dirname(__FILE__), "prompt.rb")


# Default settings
# ---------------------------------------------------------
set :default_stage, "preview"

set :scm, :git
set :deploy_via, :remote_cache
set :keep_releases, 3

set :bundle_without, [:cucumber, :development, :test]

set :httpd_user,  "apache"
set :httpd_group, "apache"

default_run_options[:pty] = true

# Default tasks
# ---------------------------------------------------------
namespace :deploy do
  desc "Symlink Shared config files into release path."
  task :symlink_config do
    run "ln -sf #{shared_path}/config/*.yml #{release_path}/config/"
  end
end


# Default hooks
# ---------------------------------------------------------
before "deploy:symlink",  "deploy:symlink_config"
after  "deploy:restart",  "deploy:cleanup"

