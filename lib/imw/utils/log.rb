require 'logger'

module IMW

  # Default log file.
  LOG_FILE_DESTINATION = STDERR             unless defined?(LOG_FILE_DESTINATION)
  
  LOG_TIMEFORMAT       = "%Y%m%d-%H:%M:%S " unless defined?(LOG_TIMEFORMAT)

  class << self; attr_accessor :log end
  
  # Create a Logger and point it at IMW::LOG_FILE_DESTINATION which is
  # set in ~/.imwrc and defaults to STDERR.
  def self.instantiate_logger!
    IMW.log ||= Logger.new(LOG_FILE_DESTINATION)
    IMW.log.datetime_format = "%Y%m%d-%H:%M:%S "
    IMW.log.level           = Logger::INFO
  end

  def announce *events
    options = events.flatten.extract_options!
    options.reverse_merge! :level => Logger::INFO
    IMW.log.add options[:level], events.join("\n")
  end
  def banner *events
    options = events.flatten.extract_options!
    options.reverse_merge! :level => Logger::INFO
    announce(["*"*75, events, "*"*75], options)
  end
  def warn *events
    options = events.flatten.extract_options!
    options.reverse_merge! :level => Logger::WARN
    announce events, options
  end

  PROGRESS_TRACKERS = {}
  #
  # When the slowly-changing tracked variable +var+ changes value,
  # announce its new value.  Always announces on first call.
  #
  # Ex:
  #   track_progress :indexing_names, name[0..0] # announce at each initial letter
  #   track_progress :files, (i % 1000)          # announce at each 1,000 iterations
  #
  def track_progress tracker, val
    unless (IMW::PROGRESS_TRACKERS.include?(tracker)) &&
           (IMW::PROGRESS_TRACKERS[tracker] == val)
      announce "#{tracker.to_s.gsub(/_/,' ')}: #{val}"
      IMW::PROGRESS_TRACKERS[tracker] = val
    end
  end

  PROGRESS_COUNTERS = {}
  #
  # Log repetitions in a given context
  #
  # At every n'th (default 1000) call,
  # announce progress in the IMW.log
  #
  def track_count tracker, every=1000
    PROGRESS_COUNTERS[tracker] ||= 0
    PROGRESS_COUNTERS[tracker]  += 1
    chunk = every * (PROGRESS_COUNTERS[tracker]/every).to_i
    track_progress "count_of_#{tracker}", chunk
  end
end

IMW.instantiate_logger!
