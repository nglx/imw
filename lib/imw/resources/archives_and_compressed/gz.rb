module IMW
  module Resources
    module CompressedFiles
      module Gz

        include IMW::Resources::CompressedFile
      
        def compression_settings
          @compression_settings ||= {
            :decompression_program  => :gunzip,
            :decompress             => '-fd'
          }
        end
        
      end
    end
  end
end
