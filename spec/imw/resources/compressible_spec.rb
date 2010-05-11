require File.join(File.dirname(__FILE__),'../../spec_helper')

describe IMW::Resources::Compressible do

  before do
    IMWTest::Random.file('foobar.txt')
    @resource = IMW::Resource.new('foobar.txt')
  end

  it "should extend a local resource " do
    @resource.is_compressible?.should be_true
    @resource.is_compressed?.should   be_false
  end

  it "can compress a resource in place" do
    compressed_file = @resource.compress!

    # only the compressed file should now exist
    compressed_file.exist?.should        be_true
    @resource.exist?.should              be_false
    
    compressed_file.is_compressed?.should   be_true
    compressed_file.is_compressible?.should be_false
  end

  it "can compress a resource without overwriting the original file" do
    compressed_file = @resource.compress

    # both files should now exist
    compressed_file.exist?.should        be_true
    @resource.exist?.should              be_true
    
    compressed_file.is_compressed?.should   be_true
    compressed_file.is_compressible?.should be_false
  end
end
