require File.dirname(__FILE__) + "/../../spec_helper"
require File.dirname(__FILE__) + "/../archive_spec"

describe IMW::Archives::Tar do
  
  before do
    @extension = 'tar'
  end

  it_should_behave_like 'an archive of files'

end




