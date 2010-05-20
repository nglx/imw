require 'imw/utils/extensions/string'
require 'imw/utils/extensions/array'
require 'imw/utils/extensions/hash'
require 'imw/utils/extensions/struct'
require 'imw/utils/extensions/symbol'

require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/object/misc'


module IMW
  # A replacement for the standard system call which raises an
  # IMW::SystemCallError if the command fails which prints better
  # debugging info.
  #
  # This function relies upon Kernel.system and obeys the same rules:
  #
  # - if +commands+ has only only a single element then no shell
  #   characters or spaces are escaped -- you have to do it yourself
  #   or you get to use shell characters, depending on your
  #   perspective.
  #
  # - if +commands+ is a list of elements then the second and further
  #   elements in the list have their shell characters and spaces
  #   escaped
  #
  # But it also has its own rules:
  #
  # - When one of the +commands+ is an empty or blank string,
  #   Kernel.system honors it and escapes it properly and sends it
  #   along for evaluation.  This can be a problem for some programs
  #   and so IMW.system excludes blank (as in <tt>blank?</tt>)
  #   elements of +commands+.
  #
  # - +commands+ will be flattened (see the gotcha below)
  #
  # Calling out to the shell like this is often brittle.  Imagine
  # defining
  #
  #   prog  = 'some_prog'
  #   flags = '-v -f'
  #   args  = 'file.txt'
  #
  # and later calling
  # 
  #   IMW.system prog, flags, args
  #
  # The space in the second argument ('-v -f') will be escaped and
  # will therefore not be properly parsed by +some_prog+.  Instead try
  #
  #   prog  = 'some_prog'
  #   flags = ['-v', '-f']
  #   args = ['file.txt']
  #   
  #   IMW.system prog, flags, *args
  #
  # which will work fine since +flags+ will automatically be flattend.
  def self.system *commands
    stripped_commands = commands.flatten.map { |command| command.to_s unless command.blank? }.compact
    IMW.announce_if_verbose(stripped_commands.join(" "))
    exit_code = Kernel.system(*stripped_commands)
    raise IMW::SystemCallError.new($?.dup, commands.join(' ')) unless $?.success?
    exit_code
  end
end


