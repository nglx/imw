module IMW
  module Parsers
    autoload :LineParser,   'imw/parsers/line_parser'
    autoload :RegexpParser, 'imw/parsers/regexp_parser'
    autoload :HtmlParser,   'imw/parsers/html_parser'
    autoload :Flat,         'imw/parsers/flat'
  end
end
