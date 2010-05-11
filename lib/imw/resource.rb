require 'ostruct'
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
  class Resource < OpenStruct

    attr_reader :uri, :mode
    
    def initialize uri, options={}
      super()
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

    def to_s
      uri.to_s
    end

    # Raise an error unless this resource exists.
    #
    # @param [String] message an optional message to include
    def should_exist!(message=nil)
      raise IMW::Error.new([message, "No path defined for #{self.inspect} extended by #{resource_modules.join(' ')}"].compact.join(', '))          unless respond_to?(:path)
      raise IMW::Error.new([message, "No exist? method defined for #{self.inspect} extended by #{resource_modules.join(' ')}"].compact.join(', ')) unless respond_to?(:exist?)
      raise IMW::PathError.new([message, "#{path} does not exist"].compact.join(', '))                                                             unless exist?
    end

    # Open a copy of this resource.
    #
    # This is useful when wanting to reset file handles.  Though -- be
    # warned -- it does not close any file handles itself...
    #
    # @return [IMW::Resource] the new (old) resource
    def reopen
      IMW.open(self.uri.to_s)
    end

    # If +method+ is a query (ends with a question mark) then return
    # the value of the open struct member with the question mark
    # removed
    #
    #   r = IMW::Resource.new
    #   r.some_method?
    #   => nil
    #   r.some_method = true
    #   r.some_method?
    #   => true
    def method_missing mid, *args
      mname = mid.id2name
      len = args.length
      if mname.chomp!('=')
        if len != 1
          raise ArgumentError, "wrong number of arguments (#{len} for 1)", caller(1)
        end
        modifiable[new_ostruct_member(mname)] = args[0]
      elsif len == 0 && mname =~ /^(.*)\?$/
        @table[$1.to_sym]
      elsif len == 0
        @table[mid]
      else
        raise NoMethodError, "undefined method `#{mname}' for #{self}, extended by #{resource_modules.join(', ')}", caller(1)
      end
    end
  end
end
