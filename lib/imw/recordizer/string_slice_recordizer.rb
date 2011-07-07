module IMW
  module Recordizer
    class StringSliceRecordizer

      attr_reader :schema

      def initialize ranges
        @schema = ranges
      end

      def recordize line
        format = schema
        case format
        when Array then slice_by_array(line, format)
        when Hash  then slice_by_hash(line, format)
        end
      end

      def slice_range string, range
        string.slice(range).strip
      end

      def slice_by_array string, format
        format.map { |range| slice_range(string, range) }
      end

      def slice_by_hash string, format
        format.inject({}) do |hsh, (key, val)|
          case val
          when Range then hsh[key] = slice_range(string, val)
          when Hash  then hsh[key] = slice_by_hash(string, val)
          end
          hsh
        end
      end

    end
  end
end
