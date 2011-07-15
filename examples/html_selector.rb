require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'imw'

class Game < IMW::Recordizer::HTMLSelectorRecordizer
  element 'td/i/a' => :name
  element 'td/a'   => :publisher
  element 'td[2]'  => :year
end

class Table < IMW::Recordizer::HTMLSelectorRecordizer

  elements "//h2/span[@id='Licensed_games']/following::table[1]/tr"   => :licensed_games,   :with => Game
  elements "//h2/span[@id='Unlicensed_games']/following::table[1]/tr" => :unlicensed_games, :with => Game

end

foo = Table.new
foo.recordize(Nokogiri::HTML(open('http://en.wikipedia.org/wiki/List_of_Nintendo_Entertainment_System_games')))

puts foo.inspect
