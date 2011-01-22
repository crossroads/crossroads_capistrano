module Crossroads
  module Capistrano
    class << self  
      def load_recipes(recipes)
        recipes.each {|r| require File.join(File.dirname(__FILE__),'crossroads_capistrano',r)}
      end
    end
  end
end
