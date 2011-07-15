module IMW
  module Serializer
    class JsonSerializer

      def initialize file_url, mode
        @file_url = file_url
        @mode     = mode
        File.open(file_url, mode)
      end

      def write line
        File.write(line)
      end

    end
  end
end
