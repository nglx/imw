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

      # Options for this Summarizer.
      attr_accessor :options

      # The inputs given to this Summarizer.
      attr_reader :inputs

      # The resources analyzed, calculated recursively from the
      # +inputs+.
      attr_reader :resources

      include IMW::Tools::ExtensionAnalyzer      

      # Initialize a new Summarizer with the given +inputs+.
      #
      # A Hash of options can be given as the last parameter.
      #
      # @param [Array<String, IMW::Resource>] inputs
      # @return [IMW::Tools::Summarizer]
      def initialize *inputs
        self.options = (inputs.last.is_a?(Hash) && inputs.pop) || {}
        self.inputs  = inputs.flatten
      end

      # Return the total size of all resources.
      #
      # @return [Integer]
      def total_size
        @total_size ||= resources.map(&:size).inject(0) { |e, sum| sum += e }
      end

      # Return a summary of the +inputs+ to this Summarizer.
      #
      # Will swallow errors.
      #
      # @return [Array<Hash>]
      def summary
        @summary ||= summary! rescue []
      end

      # Return a summary of the +inputs+ to this summarizer.
      # 
      # Delegates to the +summary+ method of each constituent
      # IMW::Resource in +inputs+.
      #
      # @return [Array]
      def summary!
        inputs.map do |input|
          (input.respond_to?(:summary) ? input.summary : {})
        end
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
        end
        @resources = inputs.map do |input|
          input.is_local? && input.is_directory? ? input.all_resources : input
        end.compact.flatten
      end

    end
  end
end
