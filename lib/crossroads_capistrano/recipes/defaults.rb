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


# Default hooks
# ---------------------------------------------------------
after  "deploy:restart",  "deploy:cleanup"

