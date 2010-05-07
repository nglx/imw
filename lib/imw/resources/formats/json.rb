module IMW
  module Resources
    module Formats
      module Json
        
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

        def dump data
          require 'json'
          write(data.to_json)
          io.close
        end
      end
    end
  end
end
