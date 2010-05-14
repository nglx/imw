module IMW
  module CompressedFiles
    module Bz2

      include IMW::CompressedFiles::Base
      
      def compression_settings
        @compression_settings ||= {
          :decompression_program    => :bzip2,
          :decompress               => '-fd'
        }
      end
      
    end
  end
end
