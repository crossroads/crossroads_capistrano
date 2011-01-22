module CrossroadsCapistrano
  @@cap_config = Capistrano::Configuration.instance(:must_exist)
  class << self  
    def load_recipes(recipes)
      @@cap_config.load do
        if recipes == :all
          # Load all available recipes.
          Dir.glob(File.join(File.dirname(__FILE__), 'crossroads_capistrano', '*.rb')).each{|f| load f}
        else
          # Load each specified recipe.
          recipes.each {|r| load File.join(File.dirname(__FILE__),'crossroads_capistrano',"#{r}.rb")}
        end
      end
    end
  end
end

