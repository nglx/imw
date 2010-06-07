require 'addressable/uri'

module IMW

  # Define this constant in your configuration file to add your own
  # URI handlers to IMW.
  USER_DEFINED_HANDLERS = [] unless defined?(USER_DEFINED_HANDLERS)

  # Register a new resource handler which dynamically extends a new
  # IMW::Resource with the given module +mod+.
  #
  # +handler+ must be one of
  #
  # 1. Regexp 
  # 2. Proc 
  # 3. +true+
  #
  # In case (1), if the regular expression matches the resource's URI
  # then the module (+mod+) will be used to extend the resource.
  #
  # In case (2), if the Proc returns a value other than +false+ or
  # +nil+ then the module will be used.
  #
  # In case (3), the module will be used.
  #
  # @param [String, Module] mod
  # @param [Regexp, Proc, true] handler
  def self.register_handler mod, handler
    raise IMW::ArgumentError.new("Module must be either a Module or String")       unless mod.is_a?(Module)    || mod.is_a?(String)
    raise IMW::ArgumentError.new("Handler must be either a Regexp, Proc, or true") unless handler.is_a?(Regexp) || handler.is_a?(Proc) || handler == true
    self::USER_DEFINED_HANDLERS << [mod, handler]
  end

  # A resource can be anything addressable via a URI.  Examples
  # include local files, remote files, webpages, &c.
  #
  # The IMW::Resource class takes a URI as input and then dynamically
  # extends itself with appropriate modules from IMW.  As an example,
  # calling
  #
  #   my_archive = IMW::Resource.new('/path/to/my/archive.tar.bz2')
  #
  # would return an IMW::Resource extended by
  # IMW::Archives::Tarbz2 (among other modules) which
  # therefore has methods for extracting, listing, and appending to
  # the archive.
  #
  # Modules are so extended based on handlers defined in the
  # <tt>imw/resources</tt> directory and accessible via
  # IMW::Resource.handlers.  You can define your own handlers by
  # defining the constant IMW::Resource::USER_DEFINED_HANDLERS in your
  # configuration file.
  #
  # The modules extending a particular IMW::Resource instance can be
  # listed as follows
  #
  #   my_archive.resource_modules #=> [IMW::Local::Base, IMW::Local::File, IMW::Local::Compressible, IMW::Archives::Tarbz2]
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
  #
  # You can also instantiate an IMW::Resource using IMW.open, which
  # accepts all the same arguments as IMW::Resource.new.
  class Resource

    attr_reader :uri, :mode

    # Create a new resource representing +uri+.
    #
    # IMW will automatically extend the resulting IMW::Resourcen
    # instance with modules appropriate to the given URI.
    #
    #   r = IMW::Resource.new("http://www.infochimps.com")
    #   r.resource_modules
    #   => [IMW::Schemes::Remote::Base, IMW::Schemes::Remote::RemoteFile, IMW::Schemes::HTTP, IMW::Formats::Html]
    #
    # You can prevent this altogether by passing in
    # <tt>:no_modules</tt>:
    #
    #   r = IMW::Resource.new("http://www.infochimps.com")
    #   r.resource_modules
    #   => [IMW::Schemes::Remote::Base, IMW::Schemes::Remote::RemoteFile, IMW::Schemes::HTTP, IMW::Formats::Html]
    #
    # And you can exert more fine-grained control with the
    # <tt>:use_modules</tt> and <tt>:skip_modules</tt> options, see
    # IMW::Resource.extend_resource! for details.
    #
    # @param [String, Addressable::URI] uri
    # @param [Hash] options
    # @option options [true, false] no_modules
    # @option options [String] mode the mode to open the resource in (will be ignored when inapplicable)
    # @return [IMW::Resource]
    def initialize uri, options={}
      self.uri = uri
      @mode    = options[:mode] || 'r'
      extend_appropriately!(options) unless options[:no_modules]
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
    # collection of handlers defined by IMW::Resource.handlers.
    #
    # Accepts the same options as Resource.extend_resource!.
    def extend_appropriately! options={}
      self.class.extend_resource!(self, options)
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
      self
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

    # If +method+ begins with the strings +is+, +on+, or +via+ and
    # ends with a question mark then we interpret it as a question
    # this resource doesn't know how to answer -- so we have it answer
    # +false+.
    #
    # As an example, consider the following loop:
    #
    #   IMW.open('/tmp').all_contents.each do |obj|
    #     if obj.is_archive?
    #       # ... do something
    #     end
    #   end
    #
    # When +obj+ is initialized and it _isn't_ an archive, then it
    # doesn't know about the <tt>is_archive?</tt> method -- but it
    # should therefore answer false anyway.
    #
    # This lets a basic text file answer questions about whether it's
    # an archive (or on S3, or accessed via some user-defined scheme,
    # &c.) without needing to know anything about archives (or S3 or
    # the user-defined scheme).
    def method_missing method, *args
      if args.empty? && method.to_s =~ /(is|on|via)_.*\?$/
        # querying for a boolean response so answer false
        return false
      else
        raise IMW::NoMethodError, "undefined method `#{method}' for #{self}, extended by #{resource_modules.join(', ')}"
      end
    end

    # Iterate through IMW::Resource.handlers and extend the given
    # +resource+ with modules whose handler conditions match the
    # resource.
    #
    # Passing in <tt>:use_modules</tt> or <tt>:skip_modules</tt>
    # allows overriding the default behavior of handlers.
    #
    # @param [IMW::Resource] resource the resource to extend
    # @param [Hash] options
    # @option options [Array<String,Module>] use_modules a list of modules used regardless of handlers
    # @option options [Array<String,Module>] skip_modules a list of modules not to be used regardless of handlers
    # @return [IMW::Resource] the extended resource
    def self.extend_resource! resource, options={}
      options.reverse_merge!(:use_modules => [], :skip_modules => [])
      handlers.each do |mod_name, handler|
        case handler
        when Regexp    then extend_resource_with_mod_or_string!(resource, mod_name, options[:skip_modules]) if handler =~ resource.uri.to_s
        when Proc      then extend_resource_with_mod_or_string!(resource, mod_name, options[:skip_modules]) if handler.call(resource)
        when TrueClass then extend_resource_with_mod_or_string!(resource, mod_name, options[:skip_modules])
        else
          raise IMW::TypeError("A handler must be Regexp, Proc, or true")
        end
      end
      options[:use_modules].each { |mod_name| extend_resource_with_mod_or_string!(resource, mod_name, options[:skip_modules]) }
      resource
    end
    
    # A list of handlers to match against each new resource.
    # 
    # When an IMW::Resource is instantiated it eventually calls
    # IMW::Resource.extend_resource! which will iterate through the
    # handlers in IMW::Resource.handlers, extending the resource with
    # modules whose handler conditions are satisfied.
    #
    # A handler is just an Array with two elements.  The first should be
    # a module or a string identifying a module.  
    #
    # If the second element is a Regexp, the corresponding module will
    # be used if the regexp matches the resource's URI (as a string)
    #
    # If the second element is a Proc, it will be called with the
    # resource as its only argument and if it returns true then the
    # module will be used.
    #
    # You can define your own handlers by appending them to
    # IMW::Resource::USER_DEFINED_HANDLERS in your <tt>.imwrc</tt>
    # file.
    #
    # The order in which handlers appear is significant --
    # IMW::CompressedFiles::HANDLERS must be _before_
    # IMW::Archives::HANDLERS, for example, because of (say)
    # <tt>.tar.bz2</tt> files.
    # 
    # @return [Array]
    def self.handlers
      # order is important!
      #
      # 
      #
      #CompressedFiles must come before
      # Archives because of tar.bz2 type files
      IMW::Schemes::HANDLERS + IMW::CompressedFiles::HANDLERS + IMW::Archives::HANDLERS + IMW::Formats::HANDLERS + USER_DEFINED_HANDLERS
    end

    protected
    # Extend +resource+ with +mod_or_string+.  Will work hard to try
    # and interpret +mod_or_string+ as a module if it's a string.
    #
    # @param [IMW::Resource] resource the resource to extend
    #
    # @param [Module, String] mod_or_string the module or string
    # representing a module to extend the resource with
    #
    # @param [Array<Module,String>] skip_modules modules to exclude
    def self.extend_resource_with_mod_or_string! resource, mod_or_string, skip_modules
      return if skip_modules.include?(mod_or_string)
      if mod_or_string.is_a?(Module)
        resource.extend(mod_or_string)
      else
        m = IMW.class_eval(mod_or_string)
        resource.extend(m) unless skip_modules.include?(m)
      end
    end    
  end
end
