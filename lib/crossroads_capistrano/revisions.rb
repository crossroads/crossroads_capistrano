desc "Show currently deployed revision on server."
task :revisions, :roles => :app do
  current, previous, latest = current_revision[0,7], previous_revision[0,7], real_revision[0,7]
  puts "\n" << "-"*63
  puts "===== Master Revision: \033[1;33m#{latest}\033[0m\n\n"
  puts "===== [ \033[1;36m#{application.capitalize} - #{stage.capitalize}\033[0m ]"
  puts "=== Deployed Revision: \033[1;32m#{current}\033[0m"
  puts "=== Previous Revision: \033[1;32m#{previous}\033[0m\n\n"
  # Show difference between master and deployed revisions.
  if (diff = `git log #{current}..#{latest} --oneline`) != ""
    diff.gsub!(/^([a-f0-9]+) /, "\033[1;32m" << '\1' << "\033[0m - ")
    diff = "    " << diff.gsub("\n", "\n    ") << "\n"
    puts "=== Difference between master revision and deployed revision:\n\n"
    puts diff
  end
end

