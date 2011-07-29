namespace :ts do

  desc "Index data for Sphinx using Thinking Sphinx's settings"
  task :in do
    run "cd #{current_path} && bundle exec rake ts:in RAILS_ENV=#{rails_env}"
  end

  desc "Stop sphinx"
  task :stop do
    run "cd #{current_path} && bundle exec rake ts:stop RAILS_ENV=#{rails_env}"
  end

  desc "Start sphinx"
  task :start do
    run "cd #{current_path} && bundle exec rake ts:start RAILS_ENV=#{rails_env}"
    run "chown #{httpd_user}:#{httpd_group} #{shared_path}/log/searchd.production.pid"
  end

  desc "Restart sphinx"
  task :restart do
    stop
    start
  end

  desc "Stop sphinx, delete index files, reindex, and restart sphinx (last resort)"
  task :recover do
    stop
    run "cd #{shared_path}/db/sphinx/ && rm -rf production"
    run "cd #{current_path} && bundle exec rake ts:in RAILS_ENV=#{rails_env}"
    start
  end

  desc """Try to discover if the indexes are corrupted. Checks for index filenames containing 'new'. \
If they exist then either the files are currently being rotated (after a reindex) or they \
are stale and need removing with ts:recover. Run this command a few times over a period of \
a minute to determine if the files disappear - indicating a successfully completed rotation \
and no need for recovery."""
  task :recovery_required? do
    run "if [ x`find #{shared_path}/db/sphinx/production/ -name \*.new.\* | wc -l` == x\"0\" ]; then echo \"Sphinx indexes look intact. Run ts:in to regenerate.\"; else echo \"Sphinx index files *may* be stale. Wait 1 minute and run this command again. Consider running ts:recover if this message appears again\"; fi"
  end

end
