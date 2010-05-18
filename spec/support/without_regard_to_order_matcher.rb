require 'set'
require 'imw/utils'

module IMWTest
  module CustomMatchers

    # Match the contents of two arrays without regard to the order
    # of their elements by treating each as a set.
    class WithoutRegardToOrder

      private
      def initialize known_array
        @known_array = known_array.to_set
      end

      public
      def matches? array_to_test
        @array_to_test = array_to_test.to_set
        @array_to_test == @known_array
      end

      def failure_message
        missing_from_array_to_test = "missing from array to test: #{(@known_array - @array_to_test).to_a.quote_items_with "and"}\n"
        missing_from_known_array = "missing from known array: #{(@array_to_test - @known_array).to_a.quote_items_with "and"}\n"
        common_to_both = "common to both: #{(@array_to_test & @known_array).to_a.quote_items_with "and"}\n"
        "expected contents of the arrays to be identical:\n\n#{missing_from_array_to_test}\n#{missing_from_known_array}\n#{common_to_both}"
      end

      def negative_failure_message
        "expected contents of the arrays to differ."
      end
    end

    # Check that the contents of one array match another without
    # regard to ordering.
    def match_without_regard_to_order known_array
      WithoutRegardToOrder.new(known_array)
    end
  end
end

