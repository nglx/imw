module IMW
  module Resources
    module Formats
      module Delimited

        attr_accessor :delimited_settings

        def load &block
          require 'fastercsv'
          FasterCSV.parse(read, delimited_options, &block)
        end

        def dump data
          require 'fastercsv'
          # FIXME can I use write instead of using the io object?
          FasterCSV.dump(data, io, delimited_options)
        end
      end

      module Csv
        include Delimited

        # Default options to be passed to
        # FasterCSV[http://fastercsv.rubyforge.org/]; see its
        # documentation for more information.
        def delimited_options
          @delimited_options ||= {
            :col_sep        => ',',
            :headers        => false,
            :return_headers => false,
            :write_headers  => true,
            :skip_blanks    => false,
            :force_quotes   => false
          }
        end
      end

      module Tsv
        include Delimited

        # Default options to be passed to
        # FasterCSV[http://fastercsv.rubyforge.org/]; see its
        # documentation for more information.
        def delimited_options
          @delimited_options ||= {
            :col_sep        => "\t",
            :headers        => false,
            :return_headers => false,
            :write_headers  => true,
            :skip_blanks    => false,
            :force_quotes   => false
          }
        end
      end
      
    end
  end
end
