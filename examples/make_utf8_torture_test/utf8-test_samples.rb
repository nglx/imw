#!/usr/bin/env ruby -w
require 'gorillib'
require 'gorillib/string/inflections'
require 'gorillib/metaprogramming/class_attribute'
require 'ap'

$LOAD_PATH.unshift(File.expand_path('../../lib', File.dirname(__FILE__)))
require 'imw/recordizer/pattern_munger'

module Utf8TortureTest
  TEST_FILENAME = File.expand_path("utf8-test_samples.txt", File.dirname(__FILE__))
  TEST_FILE     = File.open(TEST_FILENAME, "r:ASCII-8BIT")
  ALL_LINES     = TEST_FILE.readlines.map(&:chomp)
  PREAMBLE      = ALL_LINES.slice!(0..61)
  POSTAMBLE     = ALL_LINES.slice!(-1..-1)
  TEST_LINES    = ALL_LINES

  warn "unexpected content" unless (PREAMBLE[-2]    =~ /\AHere come the tests:                                                          \|\z/)
  warn "unexpected content" unless (POSTAMBLE.first =~ /\ATHE END                                                                       \|\z/)

  LINE_TERM = " "*78 + '|'

  TestLine = Struct.new(:subsection, :p1, :idx, :name, :unicode, :hex, :str, :non_printable) do
    def to_s
      test_name = name
      if test_name.blank? then test_name = subsection + (unicode ? " (#{unicode})" : '') ; end
      "%6s %-86s|\t%s %-30s|\t%-30s|\t%s" % [idx, test_name, (non_printable ? "!" : " "), unicode, hex, str]
    end
    def reassemble
      # return to_s
      if not str then p ["WTF", self] ; return ; end
      res = [p1, '"', str, '"'].join("")
      res + LINE_TERM[(res.length-79)..-1].to_s
    end
  end

  class Section
    attr_accessor :idx, :name, :subheaders, :comment, :rest, :test_lines
    include IMW::Recordizer::PatternMunger

    BLANK_LINE_RE    = /^ +\|$/
    TL_START         = '(\d\.\d\.\d+)  ?'
    TL_QUOTED_STRING = '"([^"]+)"'
    TL_TAIL          = ' +\|$'
    TL_U_CHAR        = 'U[\-\+][0-9A-F]+'
    HEX              = '[0-9a-f][0-9a-f]'
    HEADER_RE        = %r{^(\d)  (.*?)#{TL_TAIL}}
    SUBHEADER_RE     = %r{^(\d\.\d)  ?(.*?)#{TL_TAIL}}

    consumes(:header,  HEADER_RE, :limit => 1){|match, buf| self.idx, self.name = match.captures }
    consumes(:subheader, SUBHEADER_RE){|match, buf| subheaders << match[2] }
    consumes(:skip,    BLANK_LINE_RE)
    consumes(:special, /(You should see ([^:]+): +)#{TL_QUOTED_STRING}#{TL_TAIL}/) do |match, buf|
      p1, name, str = match.captures ; has_test_line(p1, '1.1.1', name, nil, nil, str)
    end
    consumes(:special, /(   )"(\xC0\xE0\x80\xF0\x80.*?)"#{TL_TAIL}/) do |match, buf|
      p1, str = match.captures ; has_test_line(p1, '3.4.1', nil, nil, nil, str)
    end
    consumes(:comment, /^[^\d\s]/){|match, buf| comment << match.string unless subheaders.present? }
    consumes(:test_line, /(#{TL_START}([^\(]+) +\((#{TL_U_CHAR})\): +)#{TL_QUOTED_STRING} +(\|?)$/) do |match, buf|
      non_printable = (match.captures.last != '|')
      p1, idx, name, unicode, str = match.captures ; has_test_line(p1, idx, name, unicode, nil, str, non_printable)
    end
    consumes(:test_line, /(#{TL_START}((?:#{TL_U_CHAR} )+)= ((?:#{HEX} )+) *= +)#{TL_QUOTED_STRING}#{TL_TAIL}/) do |match, buf|
      p1, idx, unicode, hex, str  = match.captures  ; has_test_line(p1, idx, nil, unicode, hex, str)
    end
    consumes(:plain_hex, /(#{TL_START}((?:#{HEX} )+)= +)#{TL_QUOTED_STRING}#{TL_TAIL}/) do |match, buf|
      p1, idx, hex, str  = match.captures   ; has_test_line(p1, idx, nil, nil, hex, str)
    end
    consumes(:test_line, /(#{TL_START}([^\:]+?)(0x#{HEX})?: +)#{TL_QUOTED_STRING}#{TL_TAIL}/) do |match, buf|
      p1, idx, name, hex, str, tail = match.captures ; has_test_line(p1, idx, name, nil, hex, str)
    end
    consumes(:cont_line, /(#{TL_START}([^\(]+? +\((0x#{HEX}-0x#{HEX})\)[,:] )) *#{TL_TAIL}/) do |match, buf|
      p1, idx, name, hex = match.captures; str = ""
      8.times do
        line = buf.shift
        if   line =~ /^       (.*?):?#{TL_TAIL}/       then name << $1
        elsif line =~ BLANK_LINE_RE                    then next
        elsif line =~ /   [ \"](.+?)[ \"] *#{TL_TAIL}/ then str << $1
        end
        break if line =~ /" +\|$/
      end
      has_test_line(p1, idx, name, nil, hex, str)
    end
    consumes(:rest,    //){|match, buf| p match.string }

    def initialize(*args)
      super
      self.subheaders = []
      self.comment    = []
      self.test_lines = []
    end

    def has_test_line(p1, idx, test_name, unicode, hex, str, non_printable=nil)
      unicode.strip! if unicode
      subsection = (subheaders.last || self.name)
      self.test_lines << TestLine.new(subsection, p1, idx, test_name, unicode, hex, str, non_printable)
    end

    def reassemble
      head = "#{idx}  #{name}"
      head = head + LINE_TERM[(head.length-79)..-1].to_s
      [ head, comment, test_lines.map(&:reassemble), ].flatten.compact.join("\n")
    end
  end

  SECTIONS   = []
  10.times do
    SECTIONS << (section = Section.new([]))
    section.munge(TEST_LINES)
    break if TEST_LINES.empty?
  end
end

include Utf8TortureTest

# f = $stdout
File.open(File.expand_path("utf8-test_output.txt", File.dirname(__FILE__)), "w:ASCII-8BIT"){|f|
  f.puts PREAMBLE
  f.puts SECTIONS.map(&:reassemble)
  f.puts POSTAMBLE
} 
