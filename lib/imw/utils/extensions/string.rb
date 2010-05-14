class String

  # Does the string end with the specified +suffix+ (stolen from
  # <tt>ActiveSupport::CoreExtensions::String::StartsEndsWith</tt>)?
  def ends_with?(suffix)
    suffix = suffix.to_s
    self[-suffix.length, suffix.length] == suffix
  end

  # Does the string start with the specified +prefix+ (stolen from
  # <tt>ActiveSupport::CoreExtensions::String::StartsEndsWith</tt>)?
  def starts_with?(prefix)
    prefix = prefix.to_s
    self[0, prefix.length] == prefix
  end

  # # Downcases a string and replaces spaces with underscores.  This
  # # works slightly differently than
  # # <tt>ActiveSupport::CoreExtensions::String::Inflections.underscore</tt>
  # # which is intended to be used for camel-cased Ruby constants.
  # #
  # #   "A long and unwieldy phrase".underscore #=> "a_long_and_unwieldy_phrase"
  # def underscore
  #   self.to_s.tr("-", "_").tr(" ","_").downcase
  # end

  # Returns the handle corresponding to this string as a symbol:
  #
  #   "A possible title of a dataset".handle #=> :a_possible_title_of_a_dataset
  def to_handle
    self.downcase.underscore.to_sym
  end

  # Dump this string into the given +uri+.
  def dump uri
    IMW.open!(uri).dump(self)
  end

end
