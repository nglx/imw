#!/usr/bin/env ruby -w
# coding: UTF-8
require 'gorillib'
require 'gorillib/string/inflections'
require 'gorillib/metaprogramming/class_attribute'
require 'yaml'
require 'yajl/json_gem'
require 'ap'

$LOAD_PATH.unshift(File.expand_path('../../lib', File.dirname(__FILE__)))
require 'imw/recordizer/pattern_munger'

$LOAD_PATH.unshift(File.expand_path('../../../../backend/icss/lib', File.dirname(__FILE__)))
require 'icss/serialization/zaml'

module Utf8TortureTest
  TEST_FILENAME = File.expand_path("utf8-test_samples.txt", File.dirname(__FILE__))
  TEST_FILE     = File.open(TEST_FILENAME, "r:ASCII-8BIT")
  TEST_LINES    = TEST_FILE.readlines.map(&:chomp)
  PREAMBLE      = TEST_LINES.slice!(0..61)
  POSTAMBLE     = TEST_LINES.slice!(-1..-1)

  warn "unexpected content" unless (PREAMBLE[-2]    =~ /\AHere come the tests:                                                          \|\z/)
  warn "unexpected content" unless (POSTAMBLE.first =~ /\ATHE END                                                                       \|\z/)
  LINE_TERM = " "*80 + '|'

  TestLine = Struct.new(:subsection, :p1, :idx, :name, :unicode, :hex, :str, :non_printable) do
    def pad_line(line)
      line + LINE_TERM[(line.length-79)..-2].to_s + (non_printable ? '' : '|')
    end
    def fullname
      (name.present? ? name : subsection) + (hex.present? ? " #{hex}" : " (#{unicode})")
    end
    def short_str
      str.gsub(/"|^\s+|\s*\n|\s*\|$/, '')
    end
    def to_s
      "%6s %-86s|\t%s %-30s|\t%-30s|\t%s" % [idx, fullname, (non_printable ? "!" : " "), unicode, hex, short_str]
    end
    def reassemble
      if str =~ /\n/
        [p1, str, pad_line("\n") ].join
      else
        pad_line([p1, '"', str, '"'].join(""))
      end
    end

    def ruby_name
      rname = fullname.gsub(/,.*/, "").gsub(/[\W_]+/, '_').gsub(/_$/, '').upcase
      rname = "HAS_#{rname}" if rname =~ /^\d/
      rname
    end

    def to_ruby
      "%-37s\t= %s" % [ruby_name, short_str.inspect] 
    end

    def to_hash
      { :name => fullname, :hex => hex, :str => short_str }
    end
  end 

  class Section
    attr_accessor :parent, :idx, :name, :subsections, :comment, :rest, :test_lines 
    include IMW::Recordizer::PatternMunger 

    def initialize(parent, *args)
      self.parent    = parent
      self.consumers = self.class.consumers.map(&:dup)
      super
      self.subsections = []
      self.comment    = []
      self.test_lines = []
    end

    BLANK_LINE_RE    = /^ +\|$/
    TL_START         = '(\d\.\d\.\d+)  ?'
    TL_QUOTED_STRING = '"([^"]+)"'
    TL_TAIL          = ' +\|$'
    TL_U_CHAR        = 'U[\-\+][0-9A-F]+'
    HEX              = '[0-9a-f][0-9a-f]'
    HEADER_RE        = %r{^(\d(\.\d)?)  ?(.*?)#{TL_TAIL}}

    consumes(:header,  HEADER_RE, :with => :munge_header)
    consumes(:skip,    BLANK_LINE_RE)
    consumes(:special, /(You should see ([^:]+): +)#{TL_QUOTED_STRING}#{TL_TAIL}/) do |match, buf|
      p1, nm, str = match.captures ; has_test_line(p1, '1.1.1', nm, nil, nil, str)
    end
    consumes(:comment, /^([^\d\s].*?)#{TL_TAIL}/){|match, buf| comment << match[1] }
    consumes(:test_line, /(#{TL_START}([^\(]+)\((#{TL_U_CHAR})\): +)#{TL_QUOTED_STRING} +(\|)?$/) do |match, buf|
      non_printable = (match.captures.last != '|')
      p1, idx, nm, unicode, str = match.captures
      has_test_line(p1, idx, nm, unicode, nil, str, non_printable)
    end
    consumes(:test_line, /(#{TL_START}((?:#{TL_U_CHAR} )+)= ((?:#{HEX} )+) *= +)#{TL_QUOTED_STRING}#{TL_TAIL}/) do |match, buf|
      p1, idx, unicode, hex, str  = match.captures  ; has_test_line(p1, idx, nil, unicode, hex, str)
    end
    consumes(:plain_hex, /(#{TL_START}((?:#{HEX} )+)= +)#{TL_QUOTED_STRING}#{TL_TAIL}/) do |match, buf|
      p1, idx, hex, str  = match.captures   ; has_test_line(p1, idx, nil, nil, hex, str)
    end
    consumes(:test_line, /(#{TL_START}([^\:]+?)(0x#{HEX})?: +)#{TL_QUOTED_STRING}#{TL_TAIL}/) do |match, buf|
      p1, idx, nm, hex, str, tail = match.captures ; has_test_line(p1, idx, nm, nil, hex, str)
    end
    consumes(:cont_line, /(#{TL_START}([^\(]+?) +\((0x#{HEX}-0x#{HEX})\)[,:] *#{TL_TAIL})/) do |match, buf|
      p1, idx, nm, hex = match.captures; str = ""
      8.times do
        line = buf.shift
        if   line =~ /^(       (.*):#{TL_TAIL})/       then p1 << "\n" << $1 ; nm << $2
        else
          str << "\n" << line
        end
        break if line =~ /" +\|$/
      end
      has_test_line(p1, idx, nm, nil, hex, str)
    end
    consumes(:special, /(   )"(.*?)"#{TL_TAIL}/) do |match, buf| 
      p1, str = match.captures ; has_test_line(p1, '3.4.1', nil, nil, nil, str)
    end
    consumes(:rest,    //){|match, buf| p ['unmatched:', match.string] }

    def munge_header(match, buf)
      idx, is_subheader, nm = match.captures
      if    self.name.blank?
        self.idx = idx ; self.name = nm ; return
      elsif (not is_subheader) || (parent != :root)
        return :stop
      else
        subsections << (subsection = Section.new(self.name))
        subsection.idx, subsection.name = idx, nm
        subsection.munge(buf) 
      end
    end

    def has_test_line(p1, idx, test_nm, unicode, hex, str, non_printable=nil)
      unicode.strip! if unicode
      subsection = (subsections.last || self.name)
      self.test_lines << TestLine.new(subsection, p1, idx, test_nm, unicode, hex, str, non_printable)
    end
    
    def pad_line(line)
      line + LINE_TERM[(line.length-79)..-1].to_s
    end 

    def reassemble
      nl = pad_line(' ')
      [
        pad_line("#{idx}  #{name}"),
        nl,
        (comment.present? ? [comment.map{|c| pad_line(c) }, nl] : []),
        subsections.map(&:reassemble),
        test_lines.map(&:reassemble),
        (parent == :root ? nil : nl),
      ].flatten.compact.join("\n")
    end

    def to_s
      [
        "#{idx}\t#{name}#{comment.present? ? ' ('+comment.join(" ")+')' : nil }:", "",
        (subsections.present? ? subsections.join("\n\n") : nil),
        test_lines.map(&:to_s),
        ].flatten.compact.join("\n")
    end

    def to_hash
      hsh = { :name => name }
      hsh[:tests]    = test_lines.map(&:to_hash) if test_lines.present?
      hsh[:sections] = subsections.map(&:to_hash) if subsections.present?
      hsh
    end

    def ruby_name
      name.gsub(/[\W_]+/, '_').gsub(/_$/, '').camelize
    end

    def to_ruby(ind='')
      comm_ind = '#      '
      str = [ ind+"#", "%s# %-4s %s"%[ind, idx+'.', name], ind+'#']
      str << "#{ind}#{comm_ind}#{comment.join("\n#{ind}#{comm_ind}")}\n#{ind}#" if comment.present? 
      if (parent == :root) then str << ind+"#"; str << "#{ind}module #{ruby_name}\n" ; ind += "  " ; end
      str << ind+test_lines.map{|s|  s.to_ruby      }.join("\n#{ind}") if test_lines.present?
      str << subsections.map{|s| s.to_ruby(ind) }.join("\n\n")       if subsections.present?
      yield(str) if block_given? && (idx == '1')
      if (parent == :root) then str << ind ; str << "  end" ; end
      str.flatten.compact.join("\n")
    end
    
  end

  SECTIONS   = []
  20.times do
    SECTIONS << (section = Section.new(:root))
    section.munge(TEST_LINES)
    break if TEST_LINES.empty?
  end
end

include Utf8TortureTest

def dump_reassembly(f=nil)
  f ||= File.open(File.expand_path("utf8-test_output.txt", File.dirname(__FILE__)), "w:ASCII-8BIT")
  f.puts PREAMBLE
  f.puts SECTIONS.map(&:reassemble)
  f.puts POSTAMBLE
end

def dump_as_text(f=$stdin)
  f.puts SECTIONS.join("\n\n")
end

RUBY_PREAMBLE = %Q{# -*- coding: utf-8 -*-
module Utf8TortureTest
}

RUBY_POSTAMBLE = %Q{
end
if $0 == __FILE__ then Utf8TortureTest::SomeCorrectUTF8Text.constants.each{|str| puts Utf8TortureTest::SomeCorrectUTF8Text.const_get(str) } ; end
}

LITERAL = [
['1.1.2', 'Internationalization as string', nil, nil, 'Iñtërnâtiônàlizætiøn'],
['1.1.3', 'Internationalization as literal', nil, nil, "I\xC3\xB1t\xC3\xABrn\xC3\xA2ti\xC3\xB4n\xC3\xA0liz\xC3\xA6ti\xC3\xB8n"],
]
# SECTIONS[0].has_test_line() # .force_encoding('ASCII-8BIT'))
# SECTIONS[0].has_test_line(

def dump_as_ruby(f=nil)
  f ||= File.open(File.expand_path("utf8_torture_test_helper.rb", File.dirname(__FILE__)), "w:UTF-8")
  f.puts(RUBY_PREAMBLE)
  SECTIONS.each do |sec|
    f.puts "  # #{'-'*75}"
    f.puts( sec.to_ruby('  ') do |lines|
      lines << %q{    INTERNATIONALIZATION_AS_STRING  = 'Iñtërnâtiônàlizætiøn'}
      lines << %q{    INTERNATIONALIZATION_AS_LITERAL = "I\xC3\xB1t\xC3\xABrn\xC3\xA2ti\xC3\xB4n\xC3\xA0liz\xC3\xA6ti\xC3\xB8n"}
    end )
    f.puts 
  end
  f.puts(RUBY_POSTAMBLE)
end

#dump_reassembly
# dump_as_text
dump_as_ruby #($stdout)

as_hsh = SECTIONS.map{|s| s.to_hash }
LITERAL.each do |idx, name, hex, unicode, str|
  as_hsh[0][:tests] << { :str => str }
end

f= File.open(File.expand_path("utf8_torture_test_helper.yaml", File.dirname(__FILE__)), "w:ASCII-8BIT")
# f.puts JSON.dump( as_hsh )
f.puts ZAML.dump( as_hsh )
 
