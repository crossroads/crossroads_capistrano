namespace :db do

  desc "Create the database.yml file"
  task :create_database_yml do
    prompt_with_default("Database name", :db_name, "#{application}_#{stage}")
    prompt_with_default("Database username", :db_username, "#{application}_#{stage}")
    prompt_with_default("Database password", :db_password, "#{application}_#{stage}_password")
    prompt_with_default("Database host", :db_host, "localhost")
    prompt_with_default("Database port", :db_port, "3306")
    database_yml = <<-EOF
production:
  adapter: mysql
  encoding: utf8
  database: #{db_name}
  username: #{db_username}
  password: #{db_password}
  host:     #{db_host}
  port:     #{db_port}
  pool:     10
  timeout:  5
EOF
  put database_yml, "#{deploy_to}/shared/config/database.yml"
  end


  desc "Download production database to local machine"
  task :pull do
    prompt_with_default("Database", :dbname, "#{application}_#{default_stage}")
    prompt_with_default("Database user", :username, "postgres")
    prompt_with_default("Local role", :local_role, "postgres")
    prompt_with_default("Overwrite local db? (y/n)", :overwrite, "y")
    host = find_servers(:roles => :db).map(&:to_s).first
    run "pg_dump -U #{username} #{dbname} > /tmp/dump.sql", :hosts => host
    get "/tmp/dump.sql", "tmp/dump.sql", :via => :scp, :hosts => host do |channel, name, received, total|
      print "\r#{name}: #{(Float(received)/total*100).to_i}% complete"
    end
    run "rm -rf /tmp/dump.sql", :hosts => host
    `sed -i s/stockit/#{local_role}/g tmp/dump.sql`
    # Import data.
    if overwrite.to_s.downcase[0,1] == "y"
      `psql -d stockit_development < tmp/dump.sql`
    end
  end
end

