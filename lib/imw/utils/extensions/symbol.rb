class Symbol

  # Turn the symbol into a simple proc (stolen from
  # <tt>ActiveSupport::CoreExtensions::Symbol</tt>).
  def to_proc
    Proc.new { |*args| args.shift.__send__(self, *args) }
  end

  # Returns the symbol itself (for compatibility with
  # <tt>String.uniqnae</tt> and so on.
  def handle
    self
  end

end
