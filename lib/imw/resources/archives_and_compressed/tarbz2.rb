require 'imw/resources/archive'
require 'imw/resources/compressed_file'

module IMW
  module Resources
    module Archives
      module Tarbz2

        #
        # It's a compressed file
        #

        include IMW::Resources::CompressedFile

        def compression_settings
          @compression_settings ||= {
            :program               => :bzip2,
            :decompression_program => :bunzip2,
            :decompress            => '',
            :extension             => 'bz2'
          }
        end

        #
        # But it's also an archive
        #
        
        include IMW::Resources::Archive
        
        def archive_settings
          @archive_settings ||= {
            :program               => :tar,
            :create                => '-cf',
            :list                  => "-tjf",
            :extract               => "-xjf"
          }
        end

        # Overrides default behvaior of IMW::Files::Archive#create to
        # compress files after creating them.
        def create *input_paths
          IMW.system(archive_settings[:program], archive_settings[:create], path_between_archive_and_compression, *input_paths.flatten)
          IMW.open(path_between_archive_and_compression).compress!
        end

        def decompressed_basename
          case extname
          when '.tar.bz2' then basename[0..-5]               # .tar.bz2 => .tar
          when '.tbz2'    then basename.gsub(/tbz2$/, 'tar') # .tbz2    => .tar
          else                 basename[0..-(extname.size + 1)]
          end
        end
        

        protected
        def path_between_archive_and_compression
          File.join(dirname,name + '.tar')
        end

        public

        #
        # It's a compressed file AND an archive!
        #
        
        def extname
          case path
          when /\.tar\.bz2$/ then '.tar.bz2'
          when /\.tbz2$/     then '.tbz2'
          else               File.extname(path)
          end
        end
        
      end
    end
  end
end

