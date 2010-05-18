module IMWTest
  module CustomMatchers

    class FileContentsMatcher
      def initialize orig
        @orig = File.expand_path orig
      end

      def matches? copy
        @copy = File.expand_path copy
        File.compare(@orig,@copy)
      end

      def failure_message
        "files #{@orig} and #{@copy} are different"
      end

      def negative_failure_message
        "expected files #{@orig} and #{@copy} to differ"
      end
    end

    # Matches the contents of one file against another using
    # File.compare.
    def have_contents_matching_those_of path
      FileContentsMatcher.new(path)
    end
    
  end
end
