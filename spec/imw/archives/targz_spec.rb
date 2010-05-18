require File.dirname(__FILE__) + "/../../spec_helper"
require File.dirname(__FILE__) + "/../archives_spec"
require File.dirname(__FILE__) + "/../compressed_files_spec"

describe IMW::Archives::Targz do
  @cannot_append = true
  before do
    @extension = 'tar.gz'
  end

  it_should_behave_like 'an archive of files'
end


describe IMW::Archives::Targz do
  before do
    @extension = 'tar.gz'
  end

  it_should_behave_like 'a compressed file'
end
