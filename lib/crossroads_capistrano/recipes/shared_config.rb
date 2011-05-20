namespace :deploy do
  desc "Symlink Shared config files into release path."
  task :symlink_config do
    run "ln -sf #{shared_path}/config/*.yml #{release_path}/config/"
  end
end

before "deploy:symlink", "deploy:symlink_config"

