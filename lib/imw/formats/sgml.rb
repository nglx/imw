module IMW
  module Formats

    # Defines methods to parse SGML-derived data formats (XML, HTML,
    # &c.).  This module isn't directly used to extend resources.
    # Instead, more specific modules (e.g. -
    # IMW::Resources::Formats::Xml) are used.
    module Sgml

      # Parse this resource using Hpricot and return (or yield if
      # given a block) the resulting Hpricot::Doc.
      #
      # @return [Hpricot::Doc]
      # @yield [Hpricot::Doc]
      def load &block
        require 'hpricot'
        sgml = Hpricot(io)
        if block_given?
          yield sgml
        else
          sgml
        end
      end

      # Parse the Hpricot::Doc of this resource with the given
      # +parser+.
      #
      # The parser can either be an IMW::Parsers::HtmlParser or a
      # hash which will be used to build such a parser.  See the
      # documentation for IMW::Parsers::HtmlParser for more
      # information.
      #
      # @param [Hash, IMW::Parsers::HtmlParser] parser
      # @return [Hash] the parser's output
      def parse parser
        if parser.is_a?(IMW::Parsers::HtmlParser)
          parser.parse(load)
        else
          IMW::Parsers::HtmlParser.new(parser).parse(load)
        end
      end
    end

    # Defines methods for XML data.
    module Xml
      include Sgml
    end

    # Defines methods for XSL data.
    module Xsl
      include Sgml
    end

    # Defines methods for XHTML data.
    module Xhtml
      include Sgml
    end

    # Defines methods for HTML data.
    module Html
      include Sgml
    end

    # Defines methods for RDF data.
    module Rdf
      include Sgml
    end
  end
end
