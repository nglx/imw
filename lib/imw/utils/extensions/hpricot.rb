require 'hpricot'

module Hpricot::IMWExtensions

  # Return the contents of the first element to match +path+.
  def contents_of path
    cnts = self.at path
    cnts.inner_html if cnts
  end

  # Return the value of +attr+ for the first element to match +path+.
  def path_attr path, attr
    cnts = self.at path
    cnts.attributes[attr] if cnts
  end

  # Return the value of the +class+ attribute of the first element to
  # match +path+.
  def class_of path
    self.path_attr(path, 'class')
  end
end

class Hpricot::Elem
  include Hpricot::IMWExtensions
end

class Hpricot::Elements
  include Hpricot::IMWExtensions
end

class Hpricot::Doc
  include Hpricot::IMWExtensions
end
