module IMW
  module Archives
    module Tar

      include IMW::Archives::Base
      
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

