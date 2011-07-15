#!/usr/bin/env ruby
require 'rubygems'
require 'open-uri'
require 'nokogiri'

url  = "http://gaming.wikia.com"
list = "wiki/List_of_NES_games"
doc  = Nokogiri::HTML(open File.join(url, list))
doc.xpath('//ul/li').each do |node|
  if node.children.first['title']
    game = {}
    game['title'] = node.children.first['title'].strip
    game['link']  = File.join(url, node.children.first['href'])
    game_doc = Nokogiri::HTML(open game['link'])

    puts game.inspect
  end
end

