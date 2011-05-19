namespace :deploy do
  desc "Show currently deployed revision on server."
  task :revisions, :roles => :app do
    current, previous, latest = current_revision[0,7], previous_revision[0,7], real_revision[0,7]
    puts "\n" << "-"*63
    puts "===== Master Revision: \033[1;33m#{latest}\033[0m\n\n"
    puts "===== [ \033[1;36m#{application} - #{stage}\033[0m ]"
    puts "=== Deployed Revision: \033[1;32m#{current}\033[0m"
    puts "=== Previous Revision: \033[1;32m#{previous}\033[0m\n\n"

    # If deployed and master are the same, show the difference between the last 2 deployments.
    base_label, new_label, base_rev, new_rev = latest != current ? \
                                               ["deployed", "master", current, latest] : \
                                               ["previous", "deployed", previous, current]

    # Show difference between master and deployed revisions.
    if (diff = `git log #{base_rev}..#{new_rev} --oneline`) != ""
      # Colorize refs
      diff.gsub!(/^([a-f0-9]+) /, "\033[1;32m\\1\033[0m - ")
      diff = "    " << diff.gsub("\n", "\n    ") << "\n"
      # Indent commit messages nicely, max 80 chars per line, line has to end with space.
      diff = diff.split("\n").map{|l|l.scan(/.{1,120}/).join("\n"<<" "*14).gsub(/([^ ]*)\n {14}/m,"\n"<<" "*14<<"\\1")}.join("\n")
      puts "=== Difference between #{base_label} revision and #{new_label} revision:\n\n"
      puts diff
    end
  end
end

after "deploy", "deploy:revisions"

