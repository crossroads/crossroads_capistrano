# crossroads_recipes for using RVM on a server with capistrano.
unless Capistrano::Configuration.respond_to?(:instance)
  abort "rvm/capistrano requires Capistrano >= 2."
end

Capistrano::Configuration.instance(:must_exist).load do
  if @crossroads_recipes == :all
    # Load all available crossroads_recipes.
    @crossroads_recipes = Dir.glob(File.join(File.dirname(__FILE__), 'recipes', '*.rb'))
    @crossroads_recipes.each{|f| load f}
  else
    # Load each specified recipe.
    @crossroads_recipes.each{|recipe| require "crossroads_capistrano/recipes/" << recipe}
  end
end

