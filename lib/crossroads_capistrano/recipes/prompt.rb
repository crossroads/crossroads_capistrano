# Helper function which prompts for user input, if none selected the returned
# variable is set to the default.
# 'prompt'  -> user prompt
# 'var'     -> variable
# 'default' -> default value set if no user input is received.

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

