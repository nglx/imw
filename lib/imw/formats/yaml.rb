module IMW
  module Formats

    # Provides methods for reading and writing YAML data.
    module Yaml

      # Return the content of this resource.
      #
      # Will try to be smart about iterating over the data when
      # passed a block.
      #
      # - if the outermost YAML data structure is an array, then
      #   yield each element
      #
      # - if the outermost YAML data structure is a mapping, then
      #   yield each key, value pair
      #
      # - otherwise just yield the structure
      #
      # @return [Hash, Array, String, Fixnum] whatever the YAML contained
      def load &block
        require 'yaml'
        yaml = YAML.load(read)
        if block_given?
          case yaml
          when Array
            yaml.each      { |obj| yield obj }
          when Hash
            yaml.each_pair { |key, value| yield key, value }
          else
            yield yaml
          end
        else
          yaml
        end
      end

      # Dump the +data+ into this resource.  It must be opened for
      # writing.
      #
      # @param [Hash, String, Array, Fixnum] data the Ruby object to dump
      # @option options [true, false] :persist (false) Don't close the IO object after writing
      def dump data, options={}
        require 'yaml'
        write(data.to_yaml)
        io.close unless options[:persist]
        self
      end
    end
  end
end
