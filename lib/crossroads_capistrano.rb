# Crossroads shared capistrano recipes

if defined?(Capistrano::Configuration) && Capistrano::Configuration.instance
  require 'capistrano_colors' rescue LoadError puts "Capistrano Colors is not installed."
  Capistrano::Configuration.instance(:must_exist).load do
    set :rails_root, Dir.pwd   # For tasks that need the root directory
    
    # Automatically detect whether multistage & bundler need to be required.
    require 'capistrano/ext/multistage' if File.exists?(File.join(fetch(:rails_root), 'config', 'deploy'))
    require 'bundler/capistrano'        if File.exists?(File.join(fetch(:rails_root), 'Gemfile'))

    # Load base defaults unless disabled.
    if fetch(:base_defaults, true)
      load File.join(File.dirname(__FILE__), "crossroads_capistrano/recipes/base.rb")
    end

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

