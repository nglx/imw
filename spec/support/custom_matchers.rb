module IMWTest
  module CustomMatchers

    # Check to see whether the given directory (a String) contains the
    # given +paths+
    #
    # @param [Array<String>] paths
    def contain *paths
      paths = paths.flatten
      simple_matcher("contain #{paths.inspect}") do |given, matcher|
        given_contents = Dir[given + "/**/*"].map do |abs_path|
          abs_path[(given.length + 1)..-1]
        end
        matcher.failure_message = "expected #{given} to contain #{paths.inspect}, instead it contained #{given_contents.inspect}"
        matcher.negative_failure_message = "expected #{given} not to contain #{paths.inspect}"
        paths.all? { |path| given_contents.include?(path.gsub(/\/+$/,'')) }
      end
    end

    def exist
      simple_matcher("exist") do |given, matcher|
        matcher.failure_message = "expected #{given} to exist on disk"
        matcher.failure_message = "expected #{given} not to exist on disk"
        File.exist?(given)
      end
    end
  end
end
