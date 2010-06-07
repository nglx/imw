require 'imw/tools/extension_analyzer'

module IMW
  module Tools

    # A class for producing summary data about a collection of
    # resources.
    #
    # The Summarizer needs recursively IMW.open all files and
    # directories given so will be very cumbersome if given many
    # files.  Few large files will not cause a problem.
    class Summarizer

      # The inputs given to this Summarizer.
      attr_reader :inputs

      # The resources to this Summarizer, calculated recursively from
      # its +inputs+.
      attr_reader :resources

      include IMW::Tools::ExtensionAnalyzer      

      # Initialize a new Summarizer with the given +inputs+.
      #
      # @param [Array<String, IMW::Resource>] inputs
      # @return [IMW::Tools::Summarizer]
      def initialize *inputs
        self.inputs = inputs.flatten
      end

      # Return the total size.
      #
      # @return [Integer]
      def total_size
        @total_size ||= resources.map(&:size).inject(0) { |e, sum| sum += e }
      end

      # Return a summary of the +inputs+ to this Summarizer.
      #
      # Delegates to the +summary+ method of each constituent
      # IMW::Resource in +inputs+.
      #
      # @return [Array<Hash>]
      def summary
        @summary ||= inputs.map(&:summary)
      end

      protected
      # Set new inputs for this summarizer.
      #
      # Summarizer statistics are cached as instance variables so be
      # careful about changing inputs and then using old statistics...
      #
      # @param [Array<String, IMW::Resource>] new_inputs
      def inputs= new_inputs
        @inputs = new_inputs.map do |path_or_resource|
          input = IMW.open(path_or_resource)
          input.should_exist!("Cannot summarize.")
        end
        @resources = inputs.map do |input|
          input.is_directory? ? input.all_resources : input
        end.compact.flatten
      end

    end
  end
end
