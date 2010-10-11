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

      # Ensure that this delimited resource is described by a an
      # ordered collection of flat fields.
      def validate_schema!
        raise IMW::SchemaError.new("#{self.class} resources must be described by an ordered set of flat fields") if schema.any?(&:nested?)
      end

      # Default options to be passed to
      # FasterCSV[http://fastercsv.rubyforge.org/]; see its
      # documentation for more information.
      #
      # @return [Hash]
      def delimited_options
        @delimited_options ||= {
          :headers        => schema && schema.map { |field| field['name'] }
        }.merge(resource_options_compatible_with_faster_csv)
      end

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

      # Gives us goodies!  Needs +each+ below.
      include Enumerable
      
      # Call +block+ with each row in this delimited resource.
      def each &block
        require 'fastercsv'
        FasterCSV.new(io, delimited_options).each(&block)
      end

      # Emit a single array or an array of arrays into this resource.
      #
      # @param [Array<Array>, Array] data array or array of arrays to emit
      # @param [Hash] options
      # @option options [true, false] :persist Keep this resource's IO object open after emiting
      def emit data, options={}
        require 'fastercsv'
        data = [data] unless data.first.is_a?(Array)
        data.each do |row|
          write(FasterCSV.generate_line(row, delimited_options))
        end
        self
      end
      alias_method :<<, :emit

      # Do a heuristic check to determine whether or not the first row
      # of this delimited data is a row of headers.
      #
      # @return [true, false]
      def headers_in_first_line?
        # grab the header and up to 10 body rows
        require 'fastercsv'
        copy  = FasterCSV.new(io, resource_options_compatible_with_faster_csv.merge(:headers => false))
        header = (copy.shift || []) rescue []
        body   = 10.times.map { (copy.shift || []) rescue []}.flatten

        # guess how many elements in a row
        #size_guess = ((header.size + body.map(&:size).inject(0.0) { |e, s| s += e }).to_f / (1 + body.length).to_f).to_i
        
        # calculate the fraction of bytes that are [-A-z_] (letters +
        # underscore + hypen) for header and body and compute a
        # threshold determinant
        header_chars           = header.map(&:to_s).join
        header_schema_bytes    = header_chars.bytes.find_all { |byte| (byte >= 65 && byte <= 90) || (byte >= 97 && byte <= 122) || byte == 95 || byte == 45 }
        body_chars             = body.map(&:to_s).join
        body_schema_bytes      = body_chars.bytes.find_all { |byte| (byte >= 65 && byte <= 90) || (byte >= 97 && byte <= 122) || byte == 95 || byte == 45 }
        header_schema_fraction = header_schema_bytes.size.to_f / header_chars.size.to_f    rescue nil
        body_schema_fraction   = body_schema_bytes.size.to_f   / body_chars.size.to_f      rescue nil
        determinant            = (body_schema_fraction - header_schema_fraction).abs / 2.0 rescue nil

        # decide, setting the threshold at 0.05 based on some guesswork...
        determinant && determinant >= 0.05
      end

      # If it seems like there are headers in the first line of this
      # data then go ahead and use them to define a schema.
      #
      # Will overwrite a schema already present for this resource.
      def guess_schema!
        return unless headers_in_first_line?
        copy                        = FasterCSV.new(io, resource_options_compatible_with_faster_csv.merge(:headers => false))
        names                       = (copy.shift || []) rescue []
        self.schema                 = IMW::Metadata::Schema.new(names)
        delimited_options[:headers] = names
      end

      # Return a 10-line sample of this file.
      #
      # @return [Array<Array>]
      def snippet
        require 'fastercsv'
        returning([]) do |rows|
          row_num = 1
          each do |row|
            break if row_num > 10
            rows << row.size.times.map { |index| row[index] }
            row_num += 1
          end
        end
      end

      protected
      # An array of option names used by FasterCSV.
      FASTER_CSV_OPTION_NAMES = %w[col_sep row_sep quote_char encoding field_size_limit converters unconverted_fields headers return_headers write_headers header_converters skip_blanks force_quotes].map(&:to_sym)

      # Return the subset of options this resource was initialized
      # with that are compatible with FasterCSV (it complains when you
      # give it keywords it doesn't know).
      #
      # @return [Hash]
      def resource_options_compatible_with_faster_csv
        @compatible_options ||= returning({}) do |compatible_options|
          FASTER_CSV_OPTION_NAMES.each do |option_name|
            compatible_options[option_name] = resource_options[option_name] if resource_options.has_key?(option_name.to_sym)
          end
        end
      end
    end

    # A module for working with CSV (comma-separated value) formatted
    # data.
    #
    # @see IMW::Formats::Delimited
    module Csv
      include Delimited
      def delimited_options
        @delimited_options ||= {:col_sep => ","}.merge(super())
      end
    end

    # A module for working with TSV (tab-separated value) formatted
    # data.
    #
    # @see IMW::Formats::Delimited
    module Tsv
      include Delimited
      def delimited_options
        @delimited_options ||= {
          :col_sep        => "\t",
        }.merge(super())
      end
    end
  end
end
