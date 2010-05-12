require File.dirname(__FILE__) + "/../../../spec_helper"
require File.dirname(__FILE__) + "/../archive_spec"
require File.dirname(__FILE__) + "/../compressed_file_spec"

describe IMW::Resources::Archives::Tarbz2 do
  @cannot_append = true
  before do
    @extension = 'tar.bz2'
  end

  it_should_behave_like 'an archive of files'
end

describe IMW::Resources::Archives::Tarbz2 do
  before do
    @extension = 'tar.bz2'
  end
  it_should_behave_like 'a compressed file'
end





