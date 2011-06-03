namespace :config do
  desc "Prompt for values for all '*.yml.example' and '*.yml.<<stage>>.example' files, and upload to shared/config"
  task :setup do
    puts "\n ** Setting up shared/config files ('*.yml.example')."
    puts "      - In order to skip a file, you just need to leave any prompt blank."
    puts "      - You will need to edit the '.yml.example' files to change any hard-coded values."

    (Dir.glob("config/*.yml.example")).each do |config_file|
      unless config_file.include?("database.yml")
        skip_file = false
        filename = File.basename(config_file).gsub(/.example$/,'')
        puts "\n ** == Configuring #{filename} ...\n\n"
        config = File.open(config_file).read
        # Substitute <%=...%> with evaluated expression. (Very simple ERB)
        config.gsub!(/<%=(.+)%>/) do |string|
          eval($1)
        end
        # Substitute {{...}} with user input.
        config.gsub!(/\{\{(.+)\}\}/) do |string|
          prompt = $1
          # Keep passwords hidden.
          if prompt.downcase.include?('password')
            answer = Capistrano::CLI.password_prompt("       #{prompt}: ").strip
          else
            answer = Capistrano::CLI.ui.ask("       #{prompt}: ").strip
          end
          if answer == ""
            skip_file = true
            break
          end
          answer
        end
        if skip_file
          puts "*** ! Skipping #{filename} !"
        else
          put config, "#{shared_path}/config/#{filename}"
        end
      end
    end
  end

  desc "Pull server config to local machine (excld. database.yml)"
  task :pull do
    system("mv -f config/database.yml config/database.yml.backup")
    get_with_status "#{shared_path}/config/", ".", :via => :scp, :hosts => first_db_host, :recursive => true
    system("rm -f config/database.yml && mv -f config/database.yml.backup config/database.yml")
  end
end

