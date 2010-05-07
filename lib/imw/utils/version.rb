module IMW
  unless defined?(VERSION)
    module VERSION #:nodoc:
      MAJOR = 0
      MINOR = 0
      TINY  = 0
      
      STRING = [MAJOR, MINOR, TINY].join('.')
    end
  end
end
