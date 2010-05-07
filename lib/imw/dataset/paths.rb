module IMW
  class Dataset
    include IMW::Paths

    protected
    # Sets paths to the workflow directories for this dataset (+ripd+,
    # +rawd+, +fixd+, +pkgd+) as well as the following paths:
    #
    # script::
    #   The path to the file the dataset was initialized in.
    #
    # root::
    #   The parent directory of the file the dataset was initialized
    #   in or the value of the <tt>:root</tt> key in
    #   IMW::Dataset#options
    #
    def set_default_paths
      add_path :script, File.expand_path(eval('__FILE__'))
      add_path :root,   options[:root] || File.dirname(path_to(:script))
      workflow_dirs.each do |dir|
        add_path dir, :root, dir.to_s
      end
    end

    # Overwrite this method to set additional paths for the dataset.
    def set_paths
    end
  end
end
