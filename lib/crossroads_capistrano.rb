module CrossroadsCapistrano
  begin
    @@cap_config = Capistrano::Configuration.instance(:must_exist)
    class << self
      def load_recipes(recipes)
        @@cap_config.load do
          if recipes == :all
            # Load all available recipes.
            recipes = Dir.glob(File.join(File.dirname(__FILE__), 'crossroads_capistrano', '*.rb'))
            recipes.each{|f| load f}
          else
            # Load each specified recipe.
            recipes.each{|r| load File.join(File.dirname(__FILE__),'crossroads_capistrano',"#{r}.rb")}
          end
        end
      end
    end
  rescue LoadError => ex
    # Ignore this gem if Capistrano is not loaded.
    raise ex unless ex.message == "Please require this file from within a Capistrano recipe"
  end
end

