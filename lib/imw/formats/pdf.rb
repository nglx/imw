module IMW
  module Formats

    # Defines methods for parsing and generating PDF.
    #
    # Uses PDF::Reader for parsing and Prawn for generating.
    module Pdf

      # Return a snippet of text from this PDF.
      #
      # @return [String]
      def snippet
        begin
          require 'pdf/reader'
          snippetizer = Snippetizer.new
          PDF::Reader.file(path, snippetizer)
          snippetizer.snippet
        rescue Snippetizer::SnippetEndError
          snippetizer.snippet
        rescue
          ''
        end
      end

      # A receiver class used by PDF::Reader which agglomerates text
      # up to 1024 bytes and then bails.
      class Snippetizer

        # A custom error class that can be thrown while receiving text
        # from PDF::Reader to cut-short walking large PDF documents.
        SnippetEndError = Class.new(IMW::Error)

        # The snippet being built by this snippetizer.
        attr_accessor :snippet

        def initialize
          @snippet = ''
        end

        # Agglomerates text from PDF::Reader up to a fixed size of
        # 1024 bytes.
        #
        # Will convert a single-space line from PDF::Reader as a
        # newline character.
        #
        # FIXME How does the receiver ask PDF::Reader to abort walking
        # the document now that enough text has been returned?  Till a
        # more graceful way is found this method simply raises an
        # error, creating a GOTO...
        def show_text *params
          params.each do |string|
            if @snippet.size < 1024
              if string == ' '
                @snippet += "\n"
              else
                @snippet += string[0..1024]
              end
            else
              raise SnippetEndError.new
            end
          end
        end
        alias_method :show_text_with_positioning,      :show_text
        alias_method :move_to_next_line_and_show_text, :show_text
        alias_method :set_spacing_next_line_show_text, :show_text
      end
      
    end
  end
end

