module IMW

  # Contains modules which define the behavior of compressed files.
  module CompressedFiles
    autoload :Bz2,          'imw/compressed_files/bz2'
    autoload :Gz,           'imw/compressed_files/gz'
    autoload :Compressible, 'imw/compressed_files/compressible'

    # Handlers which include modules for compressed file formats as
    # well as the IMW::CompressedFiles::Compressible module for
    # compressing regular files.
    HANDLERS = [
                ["CompressedFiles::Compressible", Proc.new { |r| r.is_local? && r.is_file? && r.path != /\.(bz2|gz|tgz|tbz2)$/i                         } ],
                ["CompressedFiles::Gz",           Proc.new { |r| r.is_local? && r.path =~ /\.gz$/i  && r.path !~ /\.tar\.gz$/i  && r.path !~ /\.tgz$/i  } ],
                ["CompressedFiles::Bz2",          Proc.new { |r| r.is_local? && r.path =~ /\.bz2$/i && r.path !~ /\.tar\.bz2$/i && r.path !~ /\.tbz2$/i } ]    
               ]

    # Defines methods for decompressing a compressed file.  This
    # module isn't used to directly extend an IMW::Resource --
    # instead, format specific modules (e.g. -
    # IMW::Resources::CompressedFiles::Bz2) include this module and
    # further define the command-line flags &c. needed to make
    # everything work.
    module Base

      attr_accessor :compression_settings

      # Is this file compressed?
      #
      # @return [true, false]
      def is_compressed?
        true
      end

      # Can this file be compressed?
      #
      # @return [true, false]
      def is_compressible?
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
