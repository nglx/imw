module IMW
  module Formats

    # Defines methods for reading and writing JSON data.
    module Json

      include Enumerable

      # Return the content of this resource.
      #
      # Will pass a block to the outermost JSON data structure's each
      # method.
      #
      # @return [Hash, Array, String, Fixnum] whatever the JSON contained
      def load &block
        require 'json'
        json = JSON.parse(read)
        if block_given?
          json.each(&block)
        else
          json
        end
      end

      # Iterate over the elements in the JSON.
      def each &block
        load(&block)
      end

      # Dump the +data+ into this resource.  It must be opened for
      # writing.
      #
      # @param [Hash, String, Array, Fixnum] data the Ruby object to dump
      # @option options [true, false] :persist (false) Don't close the IO object after writing
      def dump data, options={}
        require 'json'
        write(data.to_json)
        io.close unless options[:persist]
        self
      end
    end
  end
end
