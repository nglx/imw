require 'imw/resource'

module IMW
  module Tools
    
    # Aggregates resources into a single local directory.
    #
    # The directory should already exist.
    #
    # Any local resources will be copied into the directory.
    #
    # Any remote resources will be downloaded into the directory.
    # 
    # If any of the resources are archives, they will first be
    # extracted, with only their contents winding up in the final
    # directory (the file hierarchy of the archive will be preserved).
    #
    # If any of the resources are compressed, they will first be
    # uncompressed before being added to the directory.
    #
    # As an example:
    # 
    #   aggregator = IMW::Tools::Aggregator.new '/path/to/agg_dir'
    #   aggregator.aggregate '/path/to/my/regular_file.tsv', '/path/to/an/archive.tar.bz2', '/path/to/my_compressed_file.gz', 'http://mywebsite.com/index.html'
    #
    # This will create a directory at <tt>/path/to/agg_dir</tt> which
    # looks like
    #
    #   path_to_agg_dir
    #   |-- regular_file.tsv
    #   |-- archive
    #   |   |-- internal_archive_file_1
    #   |   |-- internal_archive_file_2
    #   |   ...
    #   |   `-- internal_archive_file_N
    #   |-- my_compressed_file
    #   `-- index.html
    #
    # Notice that
    #
    # - the local file was copied over
    #
    # - the remote file was downloaded and copied over
    #
    # - the tar archive was first exctracted
    #
    # - the compressed file was aggregated
    #
    # This process can take a while when the constituent files are
    # large.
    class Aggregator

      attr_reader :dir

      def initialize dir
        self.dir = IMW.open(dir)
      end

      # Set the directory for this Aggregator.
      #
      # Will raise unless +new_dir+ is an existing, local directory.
      #
      # @param [String, IMW::Resource] new_dir
      # @return [IMW::Resource]
      def dir= new_dir
        @dir = IMW.open(new_dir)
        raise IMW::SchemError.new("Aggregator requires a local directory, not #{@dir}") unless @dir.is_local?
        @dir.should_exist! "Aggregator requires the aggregation directory to already exist"
        raise IMW::PathError.new("Aggregator requires a directory, not #{@dir}") unless @dir.is_directory?
        @dir
      end
      
      # Return a list of error messages for this Aggregator.
      #
      # @return [Array] the error messages
      def errors
        @errors ||= []      
      end

      # Was this archiver successful (did it not have any errors)?
      #
      # @return [true, false]
      def success?
        errors.empty?
      end

      # Aggregate the given inputs into this Aggregator's +dir+.
      #
      # @param [Array<IMW::Resource,String>] inputs
      # @return [IMW::Tools::Aggregator]
      def aggregate *paths_or_inputs
        @errors = []
        paths_or_inputs.flatten.compact.each do |path_or_input|
          input = IMW.open(path_or_input)
          if input.is_local?
            aggregate_local_input(input)
          else
            download = download_remote_input(input)
            if download.is_compressed? || download.is_archive?
              aggregate_local_input(download)
              download.rm!
            end
          end
        end
      end

      protected

      # Aggregate a local input.
      #
      # Will extract archives, decompress compressed files, and copy
      # regular files and directories (but will not recurse into
      # directories to find archives or compressed files).
      #
      # @param [IMW::Resource] input
      def aggregate_local_input input
        new_path      = File.join(dir.path, input.basename)
        case
        when input.is_archive?
          IMW.announce_if_verbose("Aggregating and extracting #{input} to #{dir}...")
          FileUtils.cd(dir.path) do
            input.extract
          end
        when input.is_compressed?
          IMW.announce_if_verbose("Decompressing #{input}...")
          input.cp(new_path).decompress!
        else
          IMW.announce_if_verbose("Copying #{input}...")
          input.cp(new_path)
        end
      end

      # Download a remote input to this Aggregator's +dir+.
      #
      # @param [IMW::Resource] input
      def download_remote_input input
        IMW.announce_if_verbose("Downloading #{input}...")
        input.cp(File.join(dir.path, input.effective_basename))
      end
      
      def add_processing_error error # :nodoc:
        IMW.logger.warn error      
        errors << error
      end
      
    end
  end
end
