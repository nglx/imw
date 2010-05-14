require File.join(File.dirname(__FILE__),'../spec_helper')

# To use this shared example group define an instance variable
# <tt>@extension</tt> in your tests:
#
#   before do
#     # Notice that there is NO leading '.'
#     @extension = 'gz'
#   end
#
#   it_should_behave_like "a compressed file"
#
# The <tt>@extension</tt> should correspond to an IMW module with a
# registered handler.

share_examples_for "a compressed file" do
  include Spec::Matchers::IMW

  before do
    @root = File.join(IMWTest::TMP_DIR, 'a_compressed_file_shared_example_group')
    FileUtils.mkdir_p(@root)
    FileUtils.cd(@root)
    IMWTest::Random.file("compressed_file.#{@extension}") # define @extension in another spec
    @compressed_file = IMW::Resource.new("compressed_file.#{@extension}")
  end

  it "should know that it is compressed" do
    @compressed_file.is_compressed?.should   be_true
    @compressed_file.is_compressible?.should be_false
  end

  it "can decompress the file in place" do
    uncompressed_file = @compressed_file.decompress!
    @compressed_file.exist?.should  be_false
    uncompressed_file.exist?.should be_true
    uncompressed_file.is_compressed?.should be_false
    uncompressed_file.is_compressible?.should be_true
  end

  it "can decompress the file without deleting the original file" do
    uncompressed_file = @compressed_file.decompress
    @compressed_file.exist?.should  be_true
    uncompressed_file.exist?.should be_true
    uncompressed_file.is_compressed?.should be_false
    uncompressed_file.is_compressible?.should be_true
  end
  
end
