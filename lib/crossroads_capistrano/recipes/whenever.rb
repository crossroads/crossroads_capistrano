#
# Updates the crontab using wheneverize
#
require 'whenever/capistrano'

set :whenever_environment, defer { stage.to_s.gsub('live','production') }
set :whenever_command, "bundle exec whenever" if fetch(:bundler, true)
