if defined? Capistrano
  # Crossroads shared capistrano recipes
  require 'capistrano/ext/multistage'
  require 'bundler/capistrano' rescue LoadError
  require 'capistrano_colors' rescue LoadError puts "Capistrano Colors is not installed."

  unless Capistrano::Configuration.respond_to?(:instance)
    abort "rvm/capistrano requires Capistrano >= 2."
  end

  Capistrano::Configuration.instance(:must_exist).load do
    set :rails_root, Dir.pwd   # For tasks that need the root directory

    def load_crossroads_recipes(recipes)
      if recipes == :all
        # Load all available crossroads_recipes.
        recipes = Dir.glob(File.join(File.dirname(__FILE__),
                                     'crossroads_capistrano', 'recipes', '*.rb'))
        recipes.each{|f| load f}
      else
        # Load each specified recipe.
        recipes.each{|r| load File.join(File.dirname(__FILE__),
                                        "crossroads_capistrano/recipes/#{r}.rb")}
      end
    end
  end
end

