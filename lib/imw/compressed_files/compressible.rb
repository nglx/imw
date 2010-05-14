module IMW

  # Default settings used when compressing files.  <tt>:program</tt>
  # defines the name of the command-line program to use,
  # <tt>:compress</tt> gives the flags to use when compressing, and
  # <tt>:extension</tt> gives the extension (_without_ the `.') added
  # by the program after compressing.
  COMPRESSION_SETTINGS = {
    :program   => 'bzip2',
    :compress  => '',
    :extension => 'bz2'
  } unless defined?(COMPRESSION_SETTINGS)

  module CompressedFiles
    
    # Defines methods for compressing a file.  The default compression
    # program is defined in IMW::COMPRESSION_SETTINGS though a
    # particular resource can change the values in its
    # +compression_settings+ hash.
    module Compressible

      # Compression settings.
      attr_accessor :compression_settings

      # Is this file compressible?
      #
      # @return [true]
      def is_compressible?
        true
      end
      
      # Defines the compression settings used for this
      # resource. <tt>:program</tt> defines the name of the
      # command-line program to use, <tt>:compress</tt> gives the
      # flags to use when compressing, and <tt>:extension</tt> gives
      # the extension (_without_ the `.') added by the program after
      # compressing.
      #
      # @return [Hash]
      def compression_settings
        @compression_settings ||= COMPRESSION_SETTINGS
      end

      # Compress this resource in place, overwriting it.
      #
      # This resource's +compression_settings+ method is used to
      # determine the method of compression.
      #
      # @return [IMW::Resource] the compressed file
      def compress!
        should_exist!("Cannot compress.")
        IMW.system(*[compression_settings[:program], compression_settings[:compress], path])
        IMW.open(File.join(dirname,basename + "." + compression_settings[:extension]))
      end

      # Compress this resource without overwriting it.
      #
      # FIXME The implementation is a little stupid as the file is
      # needlessly copied.
      #
      # @return [IMW::Resource] the compressed file
      def compress options={}
        should_exist!("Cannot compress.")
        begin
          copy = cp(path + '.imw_copy')
          compressed_file = compress!
          copy.mv(path)
          compressed_file
        ensure
          copy.mv(path) if copy.exist?
        end
      end
    end
  end
end
