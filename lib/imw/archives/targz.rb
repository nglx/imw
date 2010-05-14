module IMW
  module Archives
    module Targz

      #
      # It's a compressed file
      #

      include IMW::CompressedFiles::Base

      def compression_settings
        @compression_settings ||= {
          :program               => :gzip,
          :decompression_program => :gunzip,
          :decompress            => '',
          :extension             => 'gz'
        }
      end

      #
      # But it's also an archive
      #
      
      include IMW::Archives::Base        
      
      def archive_settings
        @archive_settings ||= {
          :program               => :tar,        
          :list                  => "-tzf",
          :create                => '-cf',            
          :extract               => "-xzf"
        }
      end

      # Overrides default behvaior of IMW::Files::Archive#create to
      # compress files after creating them.
      def create *input_paths
        IMW.system(archive_settings[:program], archive_settings[:create].split, path_between_archive_and_compression, *input_paths.flatten)
        tar = IMW.open(path_between_archive_and_compression)
        tar.compression_settings = compression_settings
        tar.compress!
      end

      def decompressed_basename
        case extname
        when '.tar.gz' then basename[0..-4]              # .tar.gz => .tar
        when '.tgz'    then basename.gsub(/tgz$/, 'tar') # .tgz    => .tar
        else                basename[0..-(extname.size + 1)]
        end
      end
      
      protected
      def path_between_archive_and_compression
        File.join(dirname,name + '.tar')
      end
      public

      #
      # It's both an archive and a compressed file!
      #

      def extname
        case path
        when /\.tar\.gz$/ then '.tar.gz'
        when /\.tgz$/     then '.tgz'
        else              File.extname(path)
        end
      end

    end
  end
end

