#
# Updates the crontab using wheneverize
#
require 'whenever/capistrano'

set :whenever_command, "bundle exec whenever" if fetch(:bundler, true)

