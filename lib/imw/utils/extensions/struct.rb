Struct.class_eval do
  def slice *attrs
    hsh = {}
    attrs.each{|attr| hsh[attr] = self.send(attr) }
    hsh
  end

  def merge *args
    self.dup.merge! *args
  end
  def merge! hashlike, &block
    raise "can't handle block arg yet" if block
    hashlike.each_pair{|k,v| self[k] = v }
    self
  end
  alias_method :update, :merge!
end
