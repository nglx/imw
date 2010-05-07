module IMW
  module Resources
    
    module CompressedFiles
      autoload :Bz2, 'imw/resources/archives_and_compressed/bz2'
      autoload :Gz, 'imw/resources/archives_and_compressed/gz'
    end

    # Defines methods for decompressing a compressed file.  This
    # module isn't used to directly extend an IMW::Resource --
    # instead, format specific modules (e.g. -
    # IMW::Resources::CompressedFiles::Bz2) include this module and
    # further define the command-line flags &c. needed to make
    # everything work.
    module CompressedFile

      attr_accessor :compression_settings

      # Is this file compressed?
      #
      # @return [true, false]
      def compressed?
        true
      end

      # Can this file be compressed?
      #
      # @return [true, false]
      def compressible?
        false
      end

      # The basename of this resource after it is decompressed
      #
      #   IMW::Resource.new('/path/to/my_file.txt.bz2').decompressed_basename
      #   => 'my_file.txt'
      #
      # @return [String] the decompressed basename
      def decompressed_basename
        basename[0..-(extname.size + 1)]
      end
      
      # The path of this resource after it is decompressed
      #
      #   IMW::Resource.new('/path/to/my_file.txt.bz2').decompressed_basename
      #   => '/path/to/my_file.txt'
      #
      # @return [String] the decompressed path
      def decompressed_path
        File.join(dirname, decompressed_basename)
      end
      
      # Decompress this file in its present directory overwriting any
      # existing files and without saving the original compressed
      # file.
      #
      # @return [IMW::Resource] the decompressed resource
      def decompress!
        should_exist!("Cannot decompress.")
        program = compression_settings[:decompression_program] || compression_settings[:program]
        FileUtils.cd(dirname) { IMW.system(program, compression_settings[:decompress], path) }
        IMW.open(decompressed_path)
      end

      # Decompress this file in its present directory, overwriting any
      # existing files while keeping the original compressed file.
      #
      # FIXME The implementation is a little stupid as the file is
      # needlessly copied.
      #
      # @return [IMW::Resource] the decompressed resource
      def decompress
        should_exist!("Cannot decompress.")
        begin
          copy = cp(path + '.imw_copy')
          regular_file = decompress!
          copy.mv(path)
          regular_file
        ensure
          copy.mv(path) if copy && copy.exist?
        end
      end

    end
  end
end



