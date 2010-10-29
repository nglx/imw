module IMW

  # Base error class which all IMW errors subclass.
  Error = Class.new(StandardError)

  # Method undefined.
  NoMethodError = Class.new(Error)

  # Type error.
  TypeError = Class.new(Error)

  # Not implemented (typically because user needs to define a method
  # when subclassing a base class).
  NotImplementedError = Class.new(Error)

  # Error during parsing.
  ParseError = Class.new(Error)

  # Error with a non-existing, invalid, or inaccessible path.
  PathError = Class.new(Error)

  # Error communicating with a remote entity.
  NetworkError = Class.new(Error)

  # Raised when a resource is of the wrong scheme.
  SchemeError = Class.new(Error)

  # Raised when a resource is of the wrong (or malformed) format.
  FormatError = Class.new(Error)

  # Bad argument.
  ArgumentError = Class.new(Error)

  # Error in defining or matching a schema.
  SchemaError = Class.new(Error)

  # An error meant to be used when a system call goes awry.  It will
  # report exit status and the process id of the offending call.
  class SystemCallError < IMW::Error

    attr_reader :status, :message

    def initialize(status, message)
      @status  = status
      @message = message
    end

    def display
      "(error code: #{status.exitstatus}, pid: #{status.pid}) #{message}"
    end

    def to_s
      "(error code: #{status.exitstatus}, pid: #{status.pid}) #{message}"
    end

  end


end
