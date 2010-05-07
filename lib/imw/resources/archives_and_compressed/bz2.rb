module IMW
  module Resources
    module CompressedFiles
      module Bz2

        include IMW::Resources::CompressedFile
      
        def compression_settings
          @compression_settings ||= {
            :decompression_program    => :bzip2,
            :decompress               => '-fd'
          }
        end
        
      end
    end
  end
end
