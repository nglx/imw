require 'imw/resources/archive'

module IMW
  module Resources
    module Archives
      module Zip

        include IMW::Resources::Archive

        def archive_settings
          @archive_settings ||= {
            :program             => :zip,
            :create              => "-qqr",
            :append              => "-qqg",
            :list                => "-l",
            :extract             => "-qqo",
            :unarchiving_program => :unzip
          }
        end

        protected
        
        # The `unzip' program outputs data in a very annoying format:
        #
        #     Archive:  data.zip
        #       Length     Date   Time    Name
        #      --------    ----   ----    ----
        #         18510  07-28-08 15:58   data/4d7Qrgz7.csv
        #          3418  07-28-08 15:41   data/7S.csv
        #         23353  07-28-08 15:41   data/g.csv
        #           711  07-28-08 15:58   data/g.xml
        #          1095  07-28-08 15:41   data/L.xml
        #          2399  07-28-08 15:58   data/mTAu9H3.xml
        #           152  07-28-08 15:58   data/vaHBS2t5R.dat
        #      --------                   -------
        #         49638                   7 files            
        #
        # which is parsed by this method.
        def archive_contents_string_to_array string
          rows = string.split("\n")
          # ignore the first 3 lines of the output and also discared the
          # last 2 (5 = 2 + 3)
          file_rows = rows[3,(rows.length - 5)]
          file_rows.map do |row|
            if row
              columns = row.lstrip.rstrip.split(' ')
              # grab the filename in the fourth column
              columns[3..-1].join(' ')
            end
          end.compact
        end
      end
    end
  end
end

      
