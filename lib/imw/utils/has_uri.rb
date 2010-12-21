require 'addressable/uri'

module IMW
  module Utils

    # Endows an including class with a wrapper for Addressable::URI
    module HasURI

      # The URI of this object.
      attr_reader :uri

      # Set the URI of this resource by parsing the given +uri+ (if
      # necessary).
      #
      # @param [String, Addressable::URI] uri the uri to parse
      def uri= uri
        if uri.is_a?(Addressable::URI)
          @uri = uri
        else
          begin
            @uri = Addressable::URI.parse(uri.to_s)
          rescue URI::InvalidURIError
            @uri = Addressable::URI.parse(URI.encode(uri.to_s))
            @encoded_uri = true
          end
        end
      end

      # The scheme of this resource.  Will be +nil+ for local resources.
      #
      # @return [String]
      def scheme
        @scheme ||= uri.scheme
      end

      # The directory name of this resource's path.
      #
      # @return [String]
      def dirname
        @dirname  ||= File.dirname(path)
      end

      # The basename of this resource's path.
      #
      # @return [String]
      def basename
        @basename ||= File.basename(path)
      end

      # Returns the extension (INCLUDING the '.') of this resource's
      # path.  Redefine this in an including class for which this is
      # weird ('.tar.gz' I'm talking to you...)
      #
      # @return [String]
      def extname
        @extname ||= File.extname(path)
      end

      # Returns the extension (WITHOUT the '.') of this resource's path.
      #
      # @return [String]
      def extension
        @extension ||= extname[1..-1] || ''
      end

      # Returns the basename of the file with its extension removed
      #
      #   IMW.open('/path/to/some_file.tar.gz').name # => some_file
      #
      # @return [String]
      def name
        @name ||= extname ? basename[0,basename.length - extname.length] : basename
      end

      # Returns the user associated with the host of this URI.
      #
      # @return [String]
      def user
        @user ||= uri.user
      end

      # Returns the password associated with access to this URI.
      #
      # @return [String]
      def password
        @password ||= uri.password
      end
      
      # Return the fragment part of this resource's URI.
      #
      # Will likely be +nil+ for local resources.
      #
      # @return [String]
      def fragment
        @fragment ||= uri.fragment
      end

      # Return the URI of this resource with any query strings and
      # fragments removed.
      #
      # @return [URI::Generic]
      def stripped_uri
        uri_args = returning({}) do |args|
          %w[scheme userinfo host port path].each do |method|
            args[method.to_sym] = respond_to?(method) ? send(method) : uri.send(method)
          end
        end
        uri.class.new(uri_args)
      end

      # Return the path complete with query string and fragment.
      #
      # @return [String]
      def raw_path
        p = uri.path
        p += "?#{uri.query}"    unless uri.query.nil?
        p += "##{uri.fragment}" unless uri.fragment.nil?
        p
      end

      def to_s
        uri.to_s
      end
    end
  end
end
  

  
  

