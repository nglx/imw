module IMW
  module Resources
    module Formats

      # Defines methods for reading and writing JSON data.
      module Json

        # Return the content of this resource.
        #
        # Will try to be smart about iterating over the data when
        # passed a block.
        #
        # - if the outermost JSON data structure is an array, then
        #   yield each element
        #
        # - if the outermost JSON data structure is a mapping, then
        #   yield each key, value pair
        #
        # - otherwise just yield the structure
        #
        # @return [Hash, Array, String, Fixnum] whatever the JSON contained
        def load &block
          require 'json'
          json = JSON.parse(read)
          if block_given?
            case json
            when Array
              json.each      { |obj| yield obj }
            when Hash
              json.each_pair { |key, value| yield key, value }
            else
              yield json
            end
          else
            json
          end
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
end
