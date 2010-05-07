require 'ostruct'
require 'rake'

module IMW

  # An IMW version of Rake::Task
  Task             = Class.new(Rake::Task)

  # An IMW subclass of Rake:FileTask
  FileTask         = Class.new(Rake::FileTask)

  # An IMW subclass of Rake::FileCreationTask
  FileCreationTask = Class.new(Rake::FileCreationTask)

  # IMW encourages you to view a data transformation as a series of
  # interdependent steps.
  #
  # By default, IMW defines four main steps in such a transformation:
  # +rip+, +parse+, +fix+, and +package+.
  #
  # Each step is associated with a directory on disk in which it keeps
  # its files: +ripd+, +prsd+, +fixd+, and +pkgd+.
  #
  # The steps are:
  #
  # rip::
  #   Obtain data via HTTP, FTP, SCP, RSYNC, database query, &c and
  #   store the results in +ripd+.
  #
  # parse::
  #   Parse data into a structured form using a library (JSON, YAML,
  #   &c.) or using your own parser (XML, flat files, &c.) and store
  #   the results in +prsd+
  #
  # fix::
  #   Combine, filter, reconcile, and transform already structured
  #   data into a desired form and store the results in +fixd+.
  #
  # package::
  #   Archive, compress, and deliver data in its final form to some
  #   location (HTTP, FTP, SCP, RSYNC, S3, EBS, &c.), optionally
  #   storing the ouptut in +pkgd+.
  #
  # Each step depends upon the one before it.  The steps are blank by
  # default so there's no need to write code for steps you don't need
  # to use.  You can also define your own steps (using +task+ just
  # like in Rake) and hook them into these pre-defined steps (or
  # not...).
  #
  # A dataset also has an <tt>:initialize</tt> task (which by default
  # just creates the directories for these steps) which you can use to
  # hook in your own initialization tasks by making it depend on them.
  #
  # A subclass of IMW::Dataset can customize how tasks are defined by
  # overriding +define_workflow_tasks+, among other methods, and
  # introduce new tasks by overriding +define_tasks+.
  module Workflow

    include Rake::TaskManager
    # Default options passed to <tt>Rake</tt>.  Any class including
    # the <tt>Rake::TaskManager</tt> module must define a constant by
    # this name.
    DEFAULT_OPTIONS = {
      :dry_run => false,
      :trace   => false,
      :verbose => false
    }
    
    # Return a new (or existing) <tt>IMW::Task</tt> with the given
    # +name+.  Dependencies can be declared and a block passed in just
    # as in Rake.
    #
    # @param [Hash, Symbol, String] deps the name of the task (if a
    # Symbol or String) or the name of the task mapped to an Array of
    # dependencies (if a Hash)
    #
    # @return [IMW::Task] the task
    def task deps, &block
      self.define_task IMW::Task, deps, &block
    end

    # Return a new (or existing) <tt>IMW::FileTask</tt> with the given
    # +path+.  Dependencies can be declared and a block passed in just
    # as in Rake.
    #
    # @param [String, IMW::Resource] path the path to the file
    # @return [IMW::FileTask] the task
    def file path, &block
      path = path.respond_to?(:path) ? path.path : path
      self.define_task IMW::FileTask, path, &block
    end

    # Return a new (or existing) <tt>IMW::FileCreationTask</tt> with the given
    # +path+.  Dependencies can be declared and a block passed in just
    # as in Rake.
    #
    # @param [String, IMW::Resource] path the path to the file
    # @return [IMW::FileCreationTask] the task
    def file_create path, &block
      path = path.respond_to?(:path) ? path.path : path
      self.define_task IMW::FileCreationTask, path, &block
    end

    # Override this method to define default tasks for a subclass of
    # IMW::Dataset.
    def define_tasks
    end

    # The standard IMW workflow steps.
    #
    # @return [Array] the workflow step names
    def workflow_steps
      [:rip,  :parse, :fix, :package]
    end

    # The steps of the IMW workflow each correspond to a directory in
    # which it is customary that they deposit their files <em>once
    # they are finished processing</em> (so ripped files wind up in
    # the +ripd+ directory, packaged files in the +pkgd+ directory,
    # and so on).
    #
    # @return [Array] the workflow directory names
    def workflow_dirs
      [:ripd, :rawd,  :fixd, :pkgd]
    end

    protected
    
    # Convenience method for defining tasks for this workflow.
    #
    # @param [Hash, Symbol, String] deps the name of the task (if a
    # Symbol or String) or the name of the task mapped to an Array of
    # dependencies (if a Hash)
    # @param [String] comment the comment to associate to the task
    # @return [IMW::Task] the task
    def define_workflow_task deps, comment, &block
      @last_description = comment
      define_task(IMW::Task, deps, &block)
    end

    # Create all the instance variables required by Rake::TaskManager
    # and define default tasks for this dataset.
    def initialize_workflow
      @tasks = Hash.new
      @rules = Array.new
      @scope = Array.new
      @last_description = nil
      @options = OpenStruct.new(DEFAULT_OPTIONS)
      define_initialize_task
      define_workflow_tasks
      define_workflow_task_methods
      define_clean_task
      define_tasks
    end

    # Defines the <tt>:initialize</tt> task.  The only other task
    # hooked into <tt>:initialize</tt> is the
    # <tt>:create_workflow_dirs</tt> task which creates the workflow
    # directories for this dataset.
    def define_initialize_task
      define_workflow_task({:create_directories => []}, "Creates workflow directories for this dataset.") do
        workflow_dirs.each do |dir|
          FileUtils.mkdir_p(path_to(dir)) unless File.exist?(path_to(dir))
        end
      end
      define_workflow_task({ :initialize => [:create_directories] }, "Initialize this dataset.")
    end

    # Creates a task <tt>:clean</tt> which removes dataset's
    # workflow directories.
    def define_clean_task
      define_workflow_task :clean, "Remove the workflow directories for this dataset." do
        workflow_dirs.each do |dir|
          FileUtils.rm_rf(path_to(dir)) if File.exist?(path_to(dir))
        end
      end
    end

    # Creates the task dependency chain <tt>:package => :fix =>
    # :parse => :rip => :initialize</tt> of the
    # IMW::Workflow.
    def define_workflow_tasks
      define_workflow_task({:rip     => [:create_directories]}, "Obtain data from some source."           )
      define_workflow_task({:parse   => [:rip]},                "Parse data into a structured form."      )
      define_workflow_task({:fix     => [:parse]},              "Munge parsed data into desired form."    )
      define_workflow_task({:package => [:fix]},                "Package dataset in final form."          )
    end

    # Dynamically define methods for each of the workflow steps which
    # act as shorcuts for accessing the corresponding tasks.
    def define_workflow_task_methods
      workflow_steps.each do |step|
        self.class.class_eval <<RUBY
          def #{step} deps, &block
            self[step].enhance(step => deps, &block)
          end
RUBY
      end
    end
  end
end
