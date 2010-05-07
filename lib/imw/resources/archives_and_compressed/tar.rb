require 'imw/resources/archive'

module IMW
  module Resources
    module Archives
      module Tar

        include IMW::Resources::Archive
        
        def archive_settings
          @archive_settings ||=  {
            :create  => "-cf",
            :append  => "-rf",
            :list    => "-tf",
            :extract => "-xf",
            :program => :tar
          }
        end
      end
    end
  end
end

