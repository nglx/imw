module IMW
  module Resources
    module Formats
      module Yaml

        # Parse the data from this resource into native Ruby data
        # structures.
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

        # Dump +data+ to this resource as YAML.
        def dump data
          require 'yaml'
          write(data.to_yaml)
          io.close
        end
      end
    end
  end
end
