#
# Updates the crontab using wheneverize
#
require 'whenever/capistrano'

set :whenever_environment, defer { fetch(:stage, "").to_s.sub('live','production') }
set :whenever_command, "bundle exec whenever" if fetch(:bundler, true)
