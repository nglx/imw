require 'strscan'

class SexpistolParser < StringScanner

  def initialize(string)
    unless(string.count('(') == string.count(')'))
      raise Exception, "Missing closing parentheses"
    end
    super(string)
  end

  TOKEN_OPEN_PAREN  = '('
  TOKEN_CLOSE_PAREN = ')'
  TOKEN_APOSTROPHE  = :"'"

  def parse
    exp = []
    while true
      case fetch_token
        when TOKEN_OPEN_PAREN   then exp << parse
        when TOKEN_CLOSE_PAREN  then break
        when TOKEN_APOSTROPHE
          case fetch_token
          when '(' then exp << [:quote].concat([parse])
          else exp << [:quote, @token]
          end
        when String, Fixnum, Float, Symbol
          exp << @token
        when nil
          break
      end
    end
    exp
  end

  RE_PARENS         = /[\(\)]/
  RE_STRING_LITERAL = /"([^"\\]|\\.)*"/
  RE_FLOAT          = /[\-\+]? [0-9]+ ((e[0-9]+) | (\.[0-9]+(e[0-9]+)?))/x
  RE_INTEGER        = /[\-\+]?[0-9]+/
  RE_APOSTROPHE     = /'/
  RE_SYMBOL         = /[^\(\)\s]+/

  def fetch_token
    skip(/\s+/)
    return nil if(eos?)

    @token =
    if    scan(RE_PARENS)         then matched
    elsif scan(RE_STRING_LITERAL) then eval(matched)
    elsif scan(RE_FLOAT)          then matched.to_f
    elsif scan(RE_INTEGER)        then matched.to_i
    elsif scan(RE_APOSTROPHE)     then matched.to_sym
    elsif scan(RE_SYMBOL)         then matched.to_sym
    else     # If we've gotten here then we have an invalid token
      near = scan %r{.{0,20}}
      raise "Invalid character at position #{pos} near '#{near}'."
    end
  end

end
