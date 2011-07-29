namespace :cache do
  namespace :clear do
    desc "Clear view cache and memcache but NOT page cache (images/videos). Usually called after a restart."
    task :all do
      view
      memcache
    end
    desc "Clear memcache"
    task :memcache, :only => { :primary => true } do
      run "cd #{current_path} && bundle exec rake cache:clear RAILS_ENV=#{rails_env}"
    end
    desc "Clear view cache (tmp/cache/) used when memcached is unavailable"
    task :view do
      run "cd #{current_path} && rm -rf tmp/cache/views/"
    end
    desc "Clear page cache (public/en/) used for images and videos"
    task :page do
      run "cd #{current_path} && rm -rf public/en/"
    end
  end
end

