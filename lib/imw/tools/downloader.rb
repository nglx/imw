module IMW
  module Tools

    # A class to download a collection of resources to a shared
    # directory.
    class Downloader

      def initialize dir, *inputs
        self.dir    = dir
        self.inputs = inputs unless inputs.blank?
      end

      def self.dir= new_dir
        @dir = IMW.open(new_dir)
        raise IMW::PathError.new("#{@dir} must be a local directory") unless @dir.is_local? && @dir.is_directory?
        @dir
      end
      attr_reader :dir

      def inputs= new_inputs
        @inputs = new_inputs.flatten.compact.map { |raw_input| IMW.open(raw_input) }
      end
      attr_reader :inputs

      def downloaded_path_for input
        dir.join(input.respond_to?(:effective_basename) ? input.effective_basename : input.basename)
      end

      def download!
        before_download
        inputs.each do |input|
          downloaded_path = downloaded_path_for(input)
          IMW.log_if_verbose "Downloading #{input} to #{downloaded_path}"
          input.cp(downloaded_path)
        end
        after_download
      end

      def downloaded?
        downloaded_resources.all? { |resource| resource.exist? }
      end

      def downloaded_resources
        inputs.map do |input|
          IMW.open(downloaded_path_for(input))
        end
      end

      def clean!
        IMW.log_if_verbose("Deleting downloader directory #{dir}")
        dir.rm_rf!
      end

      def before_download
      end

      def after_download
      end

    end
  end
end

