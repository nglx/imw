require 'rubygems'
require 'bundler'
require 'bundler/setup'
require 'imw/boot'
require 'imw/utils'

# The Infinite Monkeywrench (IMW) is a Ruby library for ripping,
# extracting, parsing, munging, and packaging datasets.  It allows you
# to handle different data formats transparently as well as organize
# transformations of data as a network of dependencies (a la Make or
# Rake).
#
# IMW has a few central concepts: resources, metadata, datasets,
# workflows, and repositories.
#
# Resources represent individual data resources like local files,
# websites, databases, &c.  An IMW::Resource is typically instantiated
# via IMW.open, with IMW doing the work of figuring out what to return
# based on the URI passed in.
#
# A Resource can have a schema which describes the fields in its data.
# IMW::Metadata consists of classes which describe fields.
#
# Datasets represent collections of related data resources ..  An
# IMW::Dataset comes with a pre-defined (but customizable) workflow
# that takes data resources through several steps: rip, parse, munge,
# and package.  The workflow leverages Rake and so the various tasks
# that are necessary to process the data till it is nice and pretty
# can all be linked with dependencies.
#
# Repositories are collections of datasets and it is on these
# collections that the +imw+ command line tool operates.
module IMW
  autoload :Resource,        'imw/resource'
  autoload :Schemes,         'imw/schemes'
  autoload :Archives,        'imw/archives'
  autoload :CompressedFiles, 'imw/compressed_files'
  autoload :Formats,         'imw/formats'  
  autoload :Tools,           'imw/tools'
  autoload :Parsers,         'imw/parsers'
  autoload :Dataset,         'imw/dataset'  
  autoload :Repository,      'imw/repository'
  autoload :Metadata,        'imw/metadata'

  # Open a resource at the given +uri+.  The resource will
  # automatically be extended by modules which make sense given the
  # +uri+.
  # 
  # See the documentation for IMW::Resource and the various modules
  # within IMW::Resources for more information and options.
  #
  # Passing in an IMW::Resource will simply return it.
  #
  # @param  [String, Addressable::URI, IMW::Resource] obj the URI to open
  # @param [Hash] options
  # @option options [Array<String,Module>] as same as <tt>:use_modules</tt> in IMW::Resource.extend_instance!
  # @option options [Array<String,Module>] without same as <tt>:skip_modules</tt> in IMW::Resource.extend_instance!  
  # @return [IMW::Resource] the resulting resource, property extended for the given URI
  def self.open obj, options={}, &block
    if obj.is_a?(IMW::Resource)
      resource = obj
    else
      options[:use_modules]  ||= (options[:as]      || [])
      options[:skip_modules] ||= (options[:without] || [])
      resource = IMW::Resource.new(obj, options)
    end
    if block_given?
      yield resource
      resource.close
    else
      resource
    end
  end

  # Open (and create if necessary) a directory at the given URI.
  #
  # Will automatically create directories recursively.  Options will
  # be passed to IMW.open and interpreted appropriately.  If a block
  # is passed, the directory will be created before the block is
  # yielded to.
  #
  # @param [String, IMW::Resource] uri
  # @param [Hash] options
  # @return [IMW::Resource]
  def self.dir! uri, options={}, &block
    if block_given?
      new_dir = open(uri, options.merge(:as => (options[:as] || []) + [Schemes::Local::LocalDirectory])) do |d|
        new_dir.create
        yield
      end
    else
      new_dir = open(uri, options.merge(:as => (options[:as] || []) + [Schemes::Local::LocalDirectory]))
      new_dir.create
    end
    new_dir
  end
  
  # Works the same way as IMW.open except opens the resource for
  # writing.
  #
  # @param  [String, Addressable::URI] uri the URI to open
  # @return [IMW::Resource] the resultng resource, properly extended for the given URI and opened for writing.
  def self.open! uri, options={}, &block
    open(uri, options.merge(:mode => 'w'), &block)
  end

  # The default repository in which to place datasets.  See the
  # documentation for IMW::Repository for more information on how
  # datasets and repositories fit together.
  #
  # @return [IMW::Repository] the default IMW repository
  def self.repository
    @@repository ||= IMW::Repository.new
  end

  # Create a dataset and put it in the default IMW repository.
  #
  # Evaluates the given block in the context of the new dataset.  This
  # allows you to define tasks, add paths, and use defined metadata in
  # an elegant way.
  #
  #   IMW.dataset :my_dataset do
  #   
  #     # Define some paths we're going to use
  #     add_path :original, :rawd, 'original.csv'
  #     add_path :filtered, :fixd, 'filtered.csv'
  #     add_path :package,  :pkgd, 'filtered.tar.bz2'
  #
  #     # Copy a CSV filefrom a website to this machine.
  #     rip do
  #       open('http://mysite.com/data_archives/2010/03/03.csv').cp(path_to(:original))
  #     end
  #
  #     # Filter the original CSV data by the
  #     # <tt>meets_some_condition?</tt> method we define elsewhere...
  #     munge do
  #       open!(path_to(:filtered)) do |filtered|
  #         open(path_to(:original)).each do |row|
  #           filtered << row if meets_some_condition?(row)
  #       end
  #     end
  #
  #     # Compress the filtered data to an archive.
  #     package do
  #       open(path_to(:filtered)).compress.mv(path_to(:package))
  #     end
  #   end
  #
  # See the <tt>/examples</tt> directory of the IMW distribution for
  # more examples.
  #
  # @param [Symbol, String] handle the handle to identify this dataset with
  # @param [Hash]   options a hash of options (see IMW::Dataset)
  # @return [IMW::Dataset] the new dataset
  def self.dataset handle, options={}, &block
    d = IMW::Dataset.new(handle, options.merge(:repository => IMW.repository))
    d.instance_eval(&block) if block_given?
    d
  end

end

# Works just like IMW.dataset but defined at a top-level scope.
def dataset handle, options={}, &block
  IMW.dataset(handle, options, &block)
end
