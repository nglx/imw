module IMW

  # A Repository is a collection of datasets.  It is used by the
  # command-line +imw+ tool.
  class Repository < Hash
    alias_method :datasets, :values
    alias_method :handles,  :keys
  end
  
end


