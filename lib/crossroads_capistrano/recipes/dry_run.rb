Capistrano::Configuration::Execution.instance_eval do
  def invoke_task_directly(task)
    puts " == Dry running " << task.name
  end
end

