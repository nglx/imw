module IMW
  module Ripper
    #
    # Initialize with a url base;
    # when you read a url (relative to that base),
    # * if present, we read the contents
    # * if missing,
    #   - fetch the URL,
    #   - save it in :ripd at the relative path,
    #   - read the contents back to you
    #
    # Please DO NOT make this any fancier. There's a right way to do this, and
    # somebody out there has done so. This is a hack for only the very very simple
    # case  covered here.
    class HttpRipper
      attr_accessor :url_base

      def initialize(url_base)
        self.url_base = url_base
      end

      def read(filename)
        dest_path = File.expand_path(filename, path_to(:ripd_dir))
        http_path = File.join(url_base, filename)

        IMW::File.if_missing(dest_path) do |f|
          Log.debug("Fetching #{dest_path} from #{http_path}")
          f << open(http_path).read
        end
        IMW::File.read(dest_path)
      end

    end
  end

end
