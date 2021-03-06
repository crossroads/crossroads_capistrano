namespace :deploy do
  desc "Show currently deployed revision on server."
  task :revisions, :roles => :app do
    stage_str = exists?(:stage) ? ' ' << stage.to_s : ''
    current, previous, latest = current_revision.to_s[0,7], previous_revision.to_s[0,7], real_revision.to_s[0,7]
    # Following line 'right-aligns' the branch string.
    branch_indent = " "*(i=10-branch.size;i<0 ? 0 : i) << branch.capitalize
    current_is_deployed = current == latest
    puts "\n  * \033[0;32m== Showing revisions and diffs for [\033[1;32m#{application}#{stage_str}\033[0;32m]\033[0m\n\n"
    puts "         \033[1;33m#{branch_indent} Branch: \033[1;37m#{latest}\033[0m"
    puts "         \033[#{current == latest ? 1 : 0};33mDeployed Revision: \033[#{current == latest ? 1 : 0};37m#{current}\033[0m"
    puts "         \033[#{previous == latest ? 1 : 0};33mPrevious Revision: \033[#{previous == latest ? 1 : 0};37m#{previous}\033[0m\n\n"

    # If deployed and master are the same, show the difference between the last 2 deployments.
    base_label, new_label, base_rev, new_rev = latest != current ? \
                                               ["deployed revision", "#{branch} branch", current, latest] : \
                                               ["previous revision", "deployed revision", previous, current]

    # Show difference between master and deployed revisions.
    if (diff = `git log #{base_rev}..#{new_rev} --oneline 2>&1`) != ""
      if diff.include?("unknown revision or path not in the working tree")
        puts "  * You have deployed code that is not in your local repo.\n" +
             "    Please run 'git pull', then 'cap#{stage_str} deploy:revisions'"
      else
        # Colorize refs
        diff.gsub!(/^([a-f0-9]+) /, "\033[1;37m\\1\033[0m: ")
        diff = "         " << diff.gsub("\n", "\n         ") << "\n"
        # Indent commit messages nicely, max 80 chars per line, line has to end with space.
        diff = diff.split("\n").map{|l|l.scan(/.{1,120}/).join("\n"<<" "*19).gsub(/([^ ]*)\n {19}/m,"\n"<<" "*19<<"\\1")}.join("\n")
        puts "  * \033[0;32m== Difference between \033[1;32m#{base_label}\033[0;32m and \033[1;32m#{new_label}\033[0;32m:\033[0m\n\n"
        puts diff
      end
    end
  end
end

after NotificationTasks, "deploy:revisions"

