require 'imw/dataset/workflow'
require 'imw/dataset/paths'

module IMW

  # The IMW::Dataset represents a common object in which paths, data
  # resources, and various tasks can be intermingled to define a
  # complex transformation of data.
  #
  # == Organizing Paths
  #
  # IMW encourages you to work within the following directory
  # structure for a dataset +my_dataset+:
  #
  #   my_dataset/
  #   |-- my_dataset.rb
  #   |-- ripd
  #   |   `-- ...
  #   |-- rawd
  #   |   `-- ...
  #   |-- fixd
  #   |   `-- ...
  #   `-- pkgd
  #       `-- ...
  #
  # Just like IMW itself, a dataset can manage a collection of paths.
  # If <tt>my_dataset.rb</tt> defines a dataset:
  #
  #   # my_dataset/my_dataset.rb
  #   dataset = IMW::Dataset.new(:my_dataset)
  #
  # then the following paths will be defined:
  #
  #   dataset.path_to(:root)   #=> my_dataset
  #   dataset.path_to(:script) #=> my_dataset/my_dataset.rb
  #   dataset.path_to(:ripd)   #=> my_dataset/ripd
  #   dataset.path_to(:rawd)   #=> my_dataset/rawd
  #   dataset.path_to(:fixd)   #=> my_dataset/fixd
  #   dataset.path_to(:pkgd)   #=> my_dataset/pkgd
  #
  # Just like IMW itself, the +dataset+ supports adding path
  # references
  #
  #   dataset.add_path(:raw_data, :ripd, 'raw_data.xml')
  #   dataset.path_to(:raw_data) #=> my_dataset/ripd/raw_data.xml
  #
  # as well as removed (via <tt>dataset.remove_path</tt>)).
  #
  # A subclass of IMW::Dataset can customize these paths be overriding
  # IMW::Dataset#set_default_paths as well as define new ones by
  # overriding IMW::Dataset#set_paths.
  #
  # Setting paths can be skipped altogether by passing the
  # <tt>:skip_paths</tt> option when instantiating a dataset:
  #
  #   dataset = IMW::Dataset.new :my_dataset, :skip_paths => true
  #
  # == Utilizing Tasks
  #
  # An IMW::Dataset utilizes Rake to manage tasks needed to transform
  # data.  See IMW::Workflow for a description of the pre-defined
  # tasks (+rip+, +parse+, +fix+, +package+).
  #
  # New tasks can be defined
  #
  #   dataset.task :get_authorization do
  #     # ... get an authorization token
  #   end
  #
  # and hooked into the default tasks in the usual Rake manner
  #
  #   dataset.task :rip => [:get_authorization]
  #
  # A dataset also has methods for the workflow step tasks to make
  # this easier
  #
  #   dataset.rip [:get_authorized]
  #
  # Tasks for a dataset can be accessed and invoked as follows
  #
  #   dataset[:rip].invoke
  #
  # as well as by using the command line +imw+ tool.
  #
  # Defining tasks can be skipped altogether by passing the
  # <tt>:skip_workflow</tt> option when instantiating a dataset
  #
  #   dataset = IMW::Dataset.new :my_dataset, :skip_workflow => true
  #
  # == Working with Repositories
  #
  # A dataset can be added to a repository by passing the
  # <tt>:repository</tt> option
  #
  #   repo    = IMW::Repository.new
  #   dataset = IMW::Dataset.new :my_dataset, :repository => repo
  class Dataset

    include IMW::Workflow

    attr_accessor :handle, :options

    def initialize handle, options = {}
      @options = options
      @handle  = handle
      set_default_paths   unless options[:skip_paths]
      set_paths           unless options[:skip_paths]
      initialize_workflow unless options[:skip_workflow]
      if options[:repository]
        options[:repository][handle] = self
      end
    end

  end
end
