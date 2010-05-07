require 'addressable/uri'
require 'imw/resources'

module IMW

  # A resource can be anything addressable via a URI.  Examples
  # include local files, remote files, webpages, &c.
  #
  # The IMW::Resource class takes a URI as input and then dynamically
  # extends itself with appropriate modules from IMW::Resources.  As
  # an example, calling
  #
  #   my_archive = IMW::Resource.new('/path/to/my/archive.tar.bz2')
  #
  # would return an IMW::Resource extended by
  # IMW::Resources::Archives::Tarbz2 (among other modules) which
  # therefore has methods for extracting, listing, and appending to
  # the archive.
  #
  # Modules are so extended based on handlers defined in the
  # <tt>imw/resources</tt> directory and accessible via
  # IMW::Resources#handlers.  You can define your own handlers by
  # defining the constant IMW::Resources::USER_DEFINED_HANDLERS in
  # your configuration file.
  #
  # The modules extending a particular IMW::Resource instance can be
  # listed as follows
  #
  #   my_archive.resource_modules #=> [IMW::Resources::LocalObj, IMW::Resources::LocalFile, IMW::Resources::Compressible, IMW::Resources::Archives::Tarbz2]
  #
  # By default, resources are opened for reading.  Passing in the
  # appropriate <tt>:mode</tt> option changes this:
  #
  #   IMW::Resource.new('/path/to/my_new_file', :mode => 'w')
  #
  # If the <tt>:skip_modules</tt> option is passed in then the
  # resource will not extend itself with any modules and will
  # essentially only retain the bare functionality of a URI.  This can
  # be useful when subclassing IMW::Resource or dealing with a very
  # strange kind of resource.
  #
  # Read the documentation for modules in IMW::Resources to learn more
  # about the various behaviors an IMW::Resource can acquire.
  class Resource

    attr_reader :uri, :mode
    
    def initialize uri, options={}
      self.uri = uri
      @mode    = options[:mode] || 'r'
      extend_appropriately! unless options[:skip_modules]
    end

    # Return the modules this resource has been extended by.
    #
    # @return [Array] the modules this resource has been extended by.
    def resource_modules
      @resource_modules ||= []
    end

    # Works just like Object#extend except it keeps track of the
    # modules it has extended, see Resource#resource_modules.
    def extend mod
      resource_modules << mod
      super mod
    end

    # Extend this resource with modules by passing it through a
    # collection of handlers defined by IMW::Resources#handlers
    def extend_appropriately!
      IMW::Resources.extend_resource!(self)
    end

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

    # The host of this resource.  Will be +nil+ for local resources.
    #
    # @return [String]
    def host
      @host ||= uri.host
    end

    # The path of this resource.  For remote resources this is the
    # part past the host.
    #
    # @return [String]
    def path
      return @path if @path
      if local?
        @path = File.expand_path(uri.path)
        @path += "?#{uri.query}"           unless uri.query.blank?
        @path += "##{uri.fragment}"        unless uri.fragment.blank?
        @path = Addressable::URI.decode(s) if @encoded_uri
        @path
      else
        @path = uri.path
      end
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

    # Return the query string part of this resource's URI.  Will
    # likely be +nil+ for local resources.
    #
    # @return [String]
    def query_string
      @query_string ||= uri.query
    end

    # Return the fragment part of this resource's URI.  Will likely be
    # +nil+ for local resources.
    #
    # @return [String]
    def fragment
      @fragment ||= uri.fragment
    end
    
    # Is this file on the local machine?
    #
    # @return [true, false]
    def local?
      scheme == 'file' || scheme.nil?
    end

    # Is this file on a remote machine?
    #
    # @return [true, false]
    def remote?
      (! local?)
    end

    def to_s
      uri.to_s
    end

    def method_missing method, *args
      raise IMW::NoMethodError.new("undefined method `#{method}' for #{self.class} extended by #{resource_modules.map(&:to_s).join(', ')}")
    end
  end
end
