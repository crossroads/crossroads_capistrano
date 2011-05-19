# crossroads_recipes for using RVM on a server with capistrano.
unless Capistrano::Configuration.respond_to?(:instance)
  abort "rvm/capistrano requires Capistrano >= 2."
end

Capistrano::Configuration.instance(:must_exist).load do
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

