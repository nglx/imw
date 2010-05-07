require File.dirname(__FILE__) + "/../../../spec_helper"
require File.dirname(__FILE__) + "/../compressed_file_spec"

describe IMW::Resources::CompressedFiles::Gz do
  
  before do
    @extension = 'gz'
  end

  it_should_behave_like 'a compressed file'
end




