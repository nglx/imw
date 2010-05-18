IMW_ROOT_DIR = File.join(File.expand_path(File.dirname(__FILE__)), '..') unless defined? IMW_ROOT_DIR
IMW_SPEC_DIR = File.join(IMW_ROOT_DIR, 'spec')                           unless defined? IMW_SPEC_DIR
IMW_LIB_DIR  = File.join(IMW_ROOT_DIR, 'lib')                            unless defined? IMW_LIB_DIR
$: << IMW_LIB_DIR

require 'rubygems'
require 'spec'
require 'imw'

Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each { |path| require path }

module IMWTest
  TMP_DIR   = "/tmp/imwtest" unless defined?(TMP_DIR)
  DATA_DIR  = File.join(IMW_SPEC_DIR, 'data') unless defined?(DATA_DIR)
end

Spec::Runner.configure do |config|

  config.include IMWTest::CustomMatchers
  
  config.before do
    FileUtils.mkdir_p IMWTest::TMP_DIR
    FileUtils.cd IMWTest::TMP_DIR
  end
  
  config.after do
    FileUtils.rm_rf IMWTest::TMP_DIR
  end
end

  

