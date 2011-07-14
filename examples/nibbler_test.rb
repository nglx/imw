require 'rubygems'
require 'nibbler'
require 'open-uri'

class Game < Nibbler
  element 'td/i/a' => :name
  element 'td/a'   => :publisher
  element 'td[2]'  => :year
end

class Table < Nibbler

  elements "//h2/span[@id='Licensed_games']/following::table[1]/tr"   => :licensed_games,   :with => Game
  elements "//h2/span[@id='Unlicensed_games']/following::table[1]/tr" => :unlicensed_games, :with => Game

end

foo = Table.parse open('http://en.wikipedia.org/wiki/List_of_Nintendo_Entertainment_System_games')

puts foo.unlicensed_games[1].inspect




