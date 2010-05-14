require File.dirname(__FILE__) + "/../../spec_helper"
require File.dirname(__FILE__) + "/../compressed_files_spec"

describe IMW::CompressedFiles::Bz2 do
  
  before do
    @extension = 'bz2'
  end

  it_should_behave_like 'a compressed file'
end




