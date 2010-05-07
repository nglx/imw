require File.join(File.dirname(__FILE__),'../../spec_helper')
require File.join(File.dirname(__FILE__), '/shared_paths_spec')

describe IMW do
  before do
    @path_manager = IMW
  end
  it_should_behave_like "an object that manages paths"
end

