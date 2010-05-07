module IMW
  module Resources
    module Schemes
      module HTTP

        # Return the basename of the URI or <tt>_index</tt> if it's
        # blank, as in the case of <tt>http://www.google.com</tt>.
        def effective_basename
          (basename.blank? || basename =~ %r{^/*$}) ? "_index" : basename
        end
        
      end
    end
  end
end

