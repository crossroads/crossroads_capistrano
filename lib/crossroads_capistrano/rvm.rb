namespace :rvm do

  desc "Install rvm"
  task :install, :roles => :web do
    install_deps
    run "if ! (which rvm); then curl -s https://rvm.beginrescueend.com/install/rvm | bash; fi", :shell => 'sh'
    run "if ! (rvm list | grep #{rvm_ruby_string}); then rvm install #{rvm_ruby_string}; fi", :shell => 'sh'
  end

  task :install_deps, :roles => :web do
    yum.install( {:base => %w(curl git gcc-c++ patch readline readline-devel zlib zlib-devel libyaml-devel libffi-devel)}, :stable, :shell => 'sh' )
  end

end

before "deploy:cold", "rvm:install"
