require 'rubygems'
require 'imw/boot'
require 'imw/utils'

# The Infinite Monkeywrench (IMW) is a Ruby library for ripping,
# extracting, parsing, munging, and packaging datasets.  It allows you
# to handle different data formats transparently as well as organize
# transformations of data as a network of dependencies (a la Make or
# Rake).
#
# IMW has a few central concepts: resources, datasets, workflows, and
# repositories.
#
# Resources represent individual data resources like local files,
# websites, databases, &c.  Resources are typically instantiated via
# IMW.open, with IMW doing the work of figuring out what to return
# based on the URI passed in.
#
# Datasets represent collections of related data resources.  An
# IMW::Dataset comes with a pre-defined (but customizable) workflow
# that takes data resources through several steps: rip, parse, munge,
# and package.  The workflow leverages Rake and so the various tasks
# that are necessary to process the data till it is nice and pretty
# can all be linked with dependencies.
#
# Repositories are collections of datasets and it is on these
# collections that the +imw+ command line tool operates.
module IMW
  autoload :Resource,   'imw/resource'
  autoload :Resources,  'imw/resources'
  autoload :Repository, 'imw/repository'
  autoload :Dataset,    'imw/dataset'
  autoload :Transforms, 'imw/transforms'
  autoload :Parsers,    'imw/parsers'

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
  # @return [IMW::Resource] the resulting resource, property extended for the given URI
  def self.open obj, options={}
    return obj if obj.is_a?(IMW::Resource)
    IMW::Resource.new(obj, options)
  end

  # Works the same way as IMW.open except opens the resource for
  # writing.
  #
  # @param  [String, Addressable::URI] uri the URI to open
  # @return [IMW::Resource] the resultng resource, properly extended for the given URI and opened for writing.
  def self.open! uri, options={}
    IMW::Resource.new(uri, options.merge(:mode => 'w'))
  end

  # The default repository in which to place datasets.  See the
  # documentation for IMW::Repository for more information on how
  # datasets and repositories fit together.
  #
  # @return [IMW::Repository] the default IMW repository
  def self.repository
    @@repository ||= IMW::Repository.new
  end

  # Create a dataset and put it in the default IMW repository.  Also
  # yields the dataset so you can define its workflow
  #
  # IMW.dataset :my_dataset do
  # 
  #   # Define some paths we're going to use
  #   add_path :raw_data,  :ripd, 'raw_data.csv'
  #   add_path :fixd_data, :fixd, 'fixed_data.csv'
  #
  #   # Copy a file from a website to this dataset's +ripd+ directory.
  #   rip do
  #     IMW.open('http://mysite.com/data_archives/2010/03/03.csv').cp(path_to(:raw_data))
  #   end
  #
  #   # Filter the raw data to those values which match some criterion defined by <tt>accept?</tt>
  #   munge do
  #     IMW.open(path_to(:raw_data)).map do |row|
  #       row if accept?(row)
  #     end.compact.dump(path_to(:fixd_data))
  #   end
  #
  #   # Compress this new data
  #   package do
  #     IMW.open(path_to(:fixd_data)).compress.mv(path_to(:pkgd))
  #   end
  # end
  #
  # @param [Symbol, String] handle the handle to identify this dataset with
  # @param [Hash]   options a hash of options (see IMW::Dataset)
  # @return [IMW::Dataset] the new dataset
  def self.dataset handle, options={}, &block
    d = IMW::Dataset.new(handle, options)
    d.instance_eval(&block) if block_given?
    d
  end

end
