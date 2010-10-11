module IMW
  module Formats

    # Provides methods for reading and writing YAML data.
    module Yaml

      include Enumerable

      # Return the content of this resource.
      #
      # Will pass a block to the outermost YAML data structure's each
      # method.
      #
      # @return [Hash, Array, String, Fixnum] whatever the YAML contained
      def load &block
        require 'yaml'
        yaml = YAML.load(io)
        if block_given?
          yaml.each(&block)
        else
          yaml
        end
      end

      # Iterate over the elements in the YAML.
      def each &block
        load(&block)
      end
      
      # Emit the +data+ into this resource.  It must be opened for
      # writing.
      #
      # @param [Hash, String, Array, Fixnum] data the Ruby object to emit
      def emit data, options={}
        require 'yaml'
        write(data.to_yaml)
        self
      end
    end
  end
end
