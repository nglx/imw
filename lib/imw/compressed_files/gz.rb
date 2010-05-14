module IMW
  module CompressedFiles
    module Gz

      include IMW::CompressedFiles::Base
      
      def compression_settings
        @compression_settings ||= {
          :decompression_program  => :gunzip,
          :decompress             => '-fd'
        }
      end
      
    end
  end
end
