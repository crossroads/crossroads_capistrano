#
# Capistrano Helper Methods
#

# Returns the first host with the 'db' role. (useful for :pull commands)
def first_db_host
  @db_host ||= find_servers(:roles => :db).map(&:to_s).first
end

# Adds file status to 'get' commands
def get_with_status(file, dest, options={})
  last = nil
  get file, dest, options do |channel, name, received, total|
    print "\r      #{name}: #{(Float(received)/total*100).to_i}%"
    print "\n" if received == total
  end
end

# Test for presence of file on remote server.
def remote_file_exists?(full_path)
  capture("if [ -e #{full_path} ]; then echo 'true'; fi").strip == 'true'
end

# Replaces strings in a file, i.e. @SOME_STRING@ is replaced with 'replacement'
def sed(file, args, char="@")
  sudo "sed -i #{file} " << args.map{|k,v|"-e 's%#{char}#{k}#{char}%#{v}%g'"}.join(" ")
end

# Helper function which prompts for user input.
# If user enters nothing, variable is set to the default.
def prompt_with_default(prompt, var, default=nil)
  set(var) do
    # Append default in brackets to prompt if default is not blank.
    if default != "" && !default.nil?
      prompt << " [#{default}]"
    end
    # Keep passwords hidden.
    if prompt.downcase.include?('password')
      Capistrano::CLI.password_prompt("       #{prompt}: ")
    else
      Capistrano::CLI.ui.ask("       #{prompt}: ")
    end
  end
  set var, default if eval("#{var.to_s}.empty?")
end

