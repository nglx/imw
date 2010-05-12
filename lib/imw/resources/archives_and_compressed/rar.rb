require 'imw/resources/archive'

module IMW
  module Resources
    module Archives
      module Rar
        
        include IMW::Resources::Archive
        
        def archive_settings
          @archive_settings ||= {
            :program => :rar,
            :create  => ['a', '-o+', '-inul'],
            :append  => ['a', '-o+', '-inul'],
            :list    => "vb",
            :extract => ['x', '-o+', '-inul']
          }
        end
      end
    end
  end
end

