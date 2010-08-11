require 'imw/utils/has_uri'

module IMW

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
  #   my_archive.modules #=> [IMW::Local::Base, IMW::Local::File, IMW::Local::Compressible, IMW::Archives::Tarbz2]
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

    # The mode in which to access this resource.
    attr_accessor :mode

    # A copy of the options passed to this resource on initialization.
    attr_accessor :resource_options

    # The dataset to which this resource belongs.
    attr_accessor :dataset

    # Create a new resource representing +uri+.
    #
    # IMW will automatically extend the resulting IMW::Resource
    # instance with modules appropriate for the given URI:
    #
    #   r = IMW::Resource.new("http://www.infochimps.com")
    #   r.modules
    #   => [IMW::Schemes::Remote::Base, IMW::Schemes::Remote::RemoteFile, IMW::Schemes::HTTP, IMW::Formats::Html]
    #
    # You can prevent this altogether by passing in
    # <tt>:no_modules</tt>:
    #
    #   r = IMW::Resource.new("http://www.infochimps.com", :no_modules => true)
    #   r.modules
    #   => []
    #
    # And you can exert more fine-grained control with the
    # <tt>:use_modules</tt> and <tt>:skip_modules</tt> options, see
    # IMW::Resource.extend_instance! for details.
    #
    # @param [String, Addressable::URI] uri
    # @param [Hash] options
    # @option options [true, false] no_modules
    # @option options [String] mode the mode to open the resource in (will be ignored when inapplicable)
    # @option options [IMW::Metadata::Schema, Array] schema the schema of this resource
    # @option options [IMW::Dataset] dataset the dataset to which this resource belongs
    # @return [IMW::Resource]
    def initialize uri, options={}
      self.uri              = uri
      self.resource_options = options
      self.mode             = options[:mode] || 'r'
      self.dataset          = options[:dataset]  if options[:dataset]
      self.schema           = options[:schema]   if options[:schema]
      extend_appropriately!(options)
    end

    # Provides resources with a wrapped Addressable::URI object.
    include IMW::Utils::HasURI

    # Provides resources with a schema.
    include IMW::Metadata::Schematized
    
    # Gives IMW::Resource instances with the ability to dynamically
    # extend themselves with modules chosen from a set of handlers
    # stored by the IMW::Resource class.
    include IMW::Utils::DynamicallyExtendable
    [IMW::Schemes::HANDLERS, IMW::CompressedFiles::HANDLERS, IMW::Archives::HANDLERS, IMW::Formats::HANDLERS].each do |handlers|
      register_handlers *handlers
    end
    
    # Raise an error unless this resource exists.
    #
    # @param [String] message an optional message to include
    def should_exist!(message=nil)
      raise IMW::Error.new([message, "No path defined for #{self.inspect} extended by #{modules.join(' ')}"].compact.join(', '))          unless respond_to?(:path)
      raise IMW::Error.new([message, "No exist? method defined for #{self.inspect} extended by #{modules.join(' ')}"].compact.join(', ')) unless respond_to?(:exist?)
      raise IMW::PathError.new([message, "#{path} does not exist"].compact.join(', '))                                                    unless exist?
      self
    end

    # Open a copy of this resource.
    #
    # This is useful when wanting to reset file handles.  Though -- be
    # warned -- it does not close any file handles itself...
    #
    # @return [IMW::Resource] the new (old) resource
    def reopen
      IMW.open(uri.to_s)
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
        raise IMW::NoMethodError, "undefined method `#{method}' for #{self}, extended by #{modules.join(', ')}"
      end
    end

  end
end
