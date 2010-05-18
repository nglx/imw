require File.dirname(__FILE__) + "/../../spec_helper"
require File.dirname(__FILE__) + "/../archives_spec"

describe IMW::Archives::Rar do
  
  before do
    @extension = 'rar'
  end

  it_should_behave_like 'an archive of files'

end




