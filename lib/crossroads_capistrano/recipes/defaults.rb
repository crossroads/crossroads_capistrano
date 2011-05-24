# These defaults are always loaded unless otherwise specified

# Recipes
# ---------------------------------------------------------
load File.join(File.dirname(__FILE__), "prompt.rb")
load File.join(File.dirname(__FILE__), "config.rb")

# Settings
# ---------------------------------------------------------
set :default_stage,  "preview"
set :rails_env,      "production"

set :scm,            :git
set :branch,         "master"
set :deploy_via,     :remote_cache
set :needs_netrc,    true
set :keep_releases,  3

set :bundle_without, [:cucumber, :development, :test]

set :httpd_user,     "apache"
set :httpd_group,    "apache"
set :http_port,      "80"
set :https_port,     "443"

default_run_options[:pty] = true

# Tasks
# ---------------------------------------------------------
namespace :deploy do
  desc "Symlink Shared config files into release path."
  task :symlink_config do
    run "ln -sf #{shared_path}/config/*.yml #{release_path}/config/"
  end
end
namespace :deploy do
  desc "Check for project dependencies"
  task :check_dependencies, :roles => :db, :only => { :primary => true } do
    sudo "cd #{current_path} && RAILS_ENV=production rake check_dependencies"
  end
end

# Hooks
# ---------------------------------------------------------
before "deploy:symlink",  "deploy:symlink_config"
after  "deploy:restart",  "deploy:cleanup"

after  "deploy:check",    "deploy:check_dependencies"

# Helper Methods
# ---------------------------------------------------------
def first_db_host
  # Returns the first host with the 'db' role. (useful for :pull commands)
  @db_host ||= find_servers(:roles => :db).map(&:to_s).first
end

# Adds file status to each 'get' command
def get_with_status(file, dest, options={})
  last = nil
  get file, dest, options do |channel, name, received, total|
    print "\r      #{name}: #{(Float(received)/total*100).to_i}%"
    print "\n" if received == total
  end
end

# Replaces strings in a file, i.e. @SOME_STRING@ is replaced with 'replacement'
def sed(file, args, char="@")
  sudo "sed -i #{file} " << args.map{|k,v|"-e 's%#{char}#{k}#{char}%#{v}%g'"}.join(" ")
end

