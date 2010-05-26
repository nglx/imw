module IMW
  module Formats

    # Defines methods used for parsing and writing delimited data
    # formats (CSV, TSV, &c.)  with the FasterCSV library.  This
    # module is not used to directly extend a resource.  Instead,
    # more specific modules (e.g. - IMW::Resources::Formats::Csv)
    # include this one and also define +delimited_options+ which is
    # actually what's passed to FasterCSV.
    #
    # @abstract
    module Delimited

      include Enumerable

      attr_accessor :delimited_settings

      # Return the data in this delimited resource as an array of
      # arrays.
      #
      # Yield each outer array (row) if passed a block.
      #
      # @return [Array] the full data matrix
      # @yield [Array] each row of the data
      def load &block
        require 'fastercsv'
        FasterCSV.parse(read, delimited_options, &block)
      end

      # Call +block+ with each row in this delimited resource.
      def each &block
        load(&block)
      end

      # Dump an array of arrays into this resource.
      #
      # @param [Array] data array of arrays to dump
      # @param [Hash] options
      # @option options [true, false] :persist Keep this resource's IO object open after dumping
      def dump data, options={}
        require 'fastercsv'
        data.each do |row|
          write(FasterCSV.generate_line(row, delimited_options))
        end
        io.close unless options[:persist]
        self
      end
    end

    module Csv
      include Delimited

      # Default options to be passed to
      # FasterCSV[http://fastercsv.rubyforge.org/]; see its
      # documentation for more information.
      #
      # @return [Hash]
      def delimited_options
        @delimited_options ||= {
          :col_sep        => ',',
          :headers        => false,
          :return_headers => false,
          :write_headers  => true,
          :skip_blanks    => false,
          :force_quotes   => false
        }
      end
    end

    module Tsv
      include Delimited

      # Default options to be passed to
      # FasterCSV[http://fastercsv.rubyforge.org/]; see its
      # documentation for more information.
      #
      # @return [Hash]
      def delimited_options
        @delimited_options ||= {
          :col_sep        => "\t",
          :headers        => false,
          :return_headers => false,
          :write_headers  => true,
          :skip_blanks    => false,
          :force_quotes   => false
        }
      end
    end
  end
end
