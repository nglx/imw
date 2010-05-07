require File.dirname(__FILE__) + "/../../../spec_helper"
require File.dirname(__FILE__) + "/../archive_spec"
require File.dirname(__FILE__) + "/../compressed_file_spec"

describe IMW::Resources::Archives::Targz do
  @cannot_append = true
  before do
    @extension = 'tar.gz'
  end

  it_should_behave_like 'an archive of files'
  #it_should_behave_like 'a compressed file'
end




