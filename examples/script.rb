#!/usr/bin/env ruby

require 'rubygems'
require 'open-uri'
require 'nokogiri'
require 'fastercsv'

url = "http://www.gamespot.com/games.html?platform=19&category=&type=games&mode=all&sort=title&sortdir=desc&page="
pages = (0..27)

FasterCSV.open("nes_gamespot.csv","w", :write_headers => true, :headers => %w[ title category release ]) do |csv|
  pages.each do |page|
    doc = Nokogiri::HTML(open(url + page.to_s))
    doc.xpath("//tr").each do |node|
      game = node.content.split("\n").map {|i| i.strip }.reject { |i| i.length == 0 }
      csv << game unless game.include?("Release Date")
    end
  end
end
