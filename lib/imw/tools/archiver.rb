require 'imw/resource'

module IMW
  module Tools
    
    # Packages an Array of input files into a single output archive.
    # When the archive is extracted, all the input files given will be
    # in a single directory with a chosen name.  The path to the output
    # archive determines both the name of the archive and its type (tar,
    # tar.bz2, zip, &c.).
    # 
    # If any of the input files are themselves archives, they will first
    # be extracted, with only their contents winding up in the final
    # directory (the file hierarchy of the archive will be preserved).
    # If any of the input files are compressed, they will first be
    # uncompressed before being added to the directory.
    #
    # Both local and remote files can be archived. An exmaple:
    # 
    #   archiver = IMW::Transforms::Archiver.new 'my_archive', '/path/to/my/regular_file.tsv', '/path/to/an/archive.tar.bz2', '/path/to/my_compressed_file.gz', 'http://mywebsite.com/index.html'
    #   archiver.package! '/path/to/my_archive.zip'
    #
    # This will create a ZIP archive at
    # <tt>/path/to/my_archive.zip</tt>.  When the ZIP archive is
    # extracted its contents will look like
    #
    #   my_archive
    #   |-- regular_file.tsv
    #   |-- archive_file1
    #   |-- archive_dir
    #   |   |-- archive_file2
    #   |   `-- archive_file3
    #   |-- archive_file3
    #   |-- my_compressed_file
    #   `-- index.html
    #
    # Notice that
    #
    # - the name of the extracted directory is given by the first
    #   argument to the Archiver when it was instantiated.
    #
    # - all files wind up in the top-level of this extracted directory
    #   when possible (<tt>regular_file.tsv</tt>, <tt>index.html</tt>)
    #
    # - /path/to/archive.tar.bz2 was not directly included, but its
    #   contents (<tt>archive_file1</tt>,
    #   <tt>archive_dir/archive_file2</tt>,
    #   <tt>archive_dir/archive_file3</tt>) were included instead.
    #
    # - /path/to/my_compressed_file.gz was first uncompressed before
    #   being added to the archive.
    #
    # - the remote file <tt>http://mywebsite.com/index.html</tt> was
    #   downloaded and included
    #
    # This process can take a while when the constituent files are
    # large because there is quite a lot of preparation done to the
    # files to make this nice output structure in the final archive.
    # Further calls to <tt>package!</tt> on the same instance of
    # Archiver will skip the preparation step (the intermediate
    # results of which are sitting in IMW's temporary directory) and
    # directly create the package, saving time when attempting to
    # create multiple package formats from the same input data.
    class Archiver

      attr_accessor :name, :local_inputs, :remote_inputs

      def initialize name, *raw_inputs
        @name   = name
        self.inputs = raw_inputs
      end

      # Set the inputs for this archiver.
      #
      # @param [String, IMW::Resource] new_inputs the inputs to archive, local or remote
      def inputs= raw_inputs
        @local_inputs, @remote_inputs = [], []
        raw_inputs.flatten.each do |raw_input|
          input = IMW.open(raw_input)
          if input.is_local?
            @local_inputs << input
          else
            @remote_inputs << input
          end
        end
        @local_inputs.flatten!
      end

      # Return a list of error messages for this archiver.
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

      # A temporary directory to work in.  Its contents will
      # ultimately consist of a directory named for the package
      # containing all the input files.
      #
      # @return [String]
      def tmp_dir
        @tmp_dir ||= File.join(IMW.path_to(:tmp_root, 'packager'), (Time.now.to_i.to_s + "-" + $$.to_s)) # guaranteed unique on a node
      end

      # A directory which will contain all the content being packaged,
      # including the contents of any archives that were included in
      # the list of files to process.
      #
      # @return [String]
      def dir
        @dir ||= File.join(tmp_dir, name.to_s)
      end

      # Remove the +tmp_dir+ entirely, getting rid of all temporary
      # files.
      def clean!
        IMW.announce_if_verbose("Cleaning temporary directory #{tmp_dir}...")
        FileUtils.rm_rf(tmp_dir)
      end

      # Copy, decompress, or extract the input paths to the temporary
      # directory, readying them for packaging.
      def prepare!
        FileUtils.mkdir_p dir unless File.exist?(dir)
        
        local_inputs.each do |existing_file|
          new_path      = File.join(dir, existing_file.basename)
          case
          when existing_file.is_archive?
            IMW.announce_if_verbose("Extracting #{existing_file}...")
            FileUtils.cd(dir) do
              existing_file.extract
            end
          when existing_file.is_compressed?
            IMW.announce_if_verbose("Decompressing #{existing_file}...")
            existing_file.cp(new_path).decompress!
          else
            IMW.announce_if_verbose("Copying #{existing_file}...")
            existing_file.cp(new_path)
          end
        end
        
        remote_inputs.each do |remote_input|
          IMW.announce_if_verbose("Downloading #{remote_input}...")
          remote_input.cp(File.join(dir, remote_input.effective_basename))
        end
      end        
      
      # Checks to see if all expected files exist in the temporary
      # directory for this packager.
      #
      # @return [true, false]
      def prepared?
        local_inputs.each do |existing_file|
          case
          when existing_file.is_archive?
            existing_file.contents.each do |archived_file_path|
              return false unless File.exist?(File.join(dir, archived_file_path))
            end
          when existing_file.is_compressed?
            return false unless File.exist?(File.join(dir, existing_file.decompressed_basename))
          else
            return false unless File.exist?(File.join(dir, existing_file.basename))
          end
        end

        remote_inputs.each do |remote_input|
          return false unless File.exist?(File.join(dir, remote_input.effective_basename))
        end
        
        true
      end
      
      # Package the contents of the temporary directory to an archive
      # at +output+ but return exceptions instead of raising them.
      #
      # @param [String, IMW::Resource] output the path to the output package
      # @param [Hash] options
      # @return [StandardError, IMW::Resource] either the completed package or the error which was raised
      def package output, options={}
        begin
          package! output, options={}
        rescue StandardError => e
          return e
        end
      end

      # Package the contents of the temporary directory to an archive
      # at +output+.  The extension of +output+ determines the kind of
      # archive.
      #
      # @param [String, IMW::Resource] output the path to the output package
      # @param [Hash] options
      # @return [IMW::Resource] the completed package
      def package! output, options={}
        prepare!                          unless prepared?
        output = IMW.open(output)
        FileUtils.mkdir_p(output.dirname) unless File.exist?(output.dirname)        
        output.rm!                        if output.exist?
        FileUtils.cd(tmp_dir) { IMW.open(output.basename).create(name).mv(output.path) }
        add_processing_error "Archiver: couldn't create archive #{output.path}" unless output.exists?
        output
      end

      protected
      def add_processing_error error # :nodoc:
        IMW.logger.warn error      
        errors << error
      end
      
    end
  end
end
