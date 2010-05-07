require 'imw/utils/extensions/string'
require 'imw/utils/extensions/array'
require 'imw/utils/extensions/hash'
require 'imw/utils/extensions/struct'
require 'imw/utils/extensions/symbol'

require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/object/misc'


module IMW
  # A replacement for the standard system call which raises an
  # IMW::SystemCallError if the command fails as well as printing the
  # command appended to the end of <tt>error_message</tt>.
  def self.system *commands
    Kernel.system(*commands.map(&:to_s))
    raise IMW::SystemCallError.new($?.dup, commands.join(' ')) unless $?.success?
  end
end


