require File.join(File.dirname(__FILE__),'../spec_helper')

# To use this shared example group define instance variables
# <tt>@extension</tt> and <tt>@cannot_append</tt> in your tests:
#
#   @cannot_append = true
#   before do
#     # Notice that there is NO leading '.'
#     @extension = 'tar.bz2'
#   end
#
#   it_should_behave_like "an archive of files"
#
# The <tt>@extension</tt> should correspond to an IMW module with a
# registered handler.
#
# If <tt>@cannot_append</tt> evaluates to true then the specs for
# appending to files will check for an error (this is because one
# typically cannot append to compressed archives).  This instance
# variable should be defined OUTSIDE a before block.

share_examples_for "an archive of files" do

  before do
    @root = File.join(IMWTest::TMP_DIR, 'an_archive_of_files_shared_example_group')
    @initial_directory    = 'initial'
    @appending_directory  = 'appending'
    @extraction_directory = 'extraction'
    FileUtils.mkdir_p(@root)
    FileUtils.cd(@root)
    IMWTest::Random.directory_with_files(@initial_directory)
    IMWTest::Random.directory_with_files(@appending_directory)
    FileUtils.mkdir(@extraction_directory)
    @archive = IMW::Resource.new("archive.#{@extension}") # define @extension in another spec
  end

  it "can create an archive" do
    @archive.create(*Dir[@initial_directory + '/**/*'])
    @archive.should contain_paths_like(@initial_directory, :relative_to => @root)
  end

  it "returns an IMW resource when creating" do
    @archive.create(*Dir[@initial_directory + '/**/*']).class.should == IMW::Resource
  end

  if @cannot_append
    it "cannot append to an archive which already exists" do
      @archive.create(*Dir[@initial_directory + "/**/*"])
      lambda { @archive.append(*Dir[@appending_directory + "/**/*"]) }.should raise_error(IMW::Error)
    end
  else
    it "can append to an archive which already exists" do
      @archive.create(*Dir[@initial_directory + "/**/*"])
      @archive.append(*Dir[@appending_directory + "/**/*"])
      @archive.should contain_paths_like([@initial_directory,@appending_directory], :relative_to => @root)
    end
    
    it "can append to an archive which doesn't already exist" do
      @archive.append(*Dir[@appending_directory + "/**/*"])    
      @archive.should contain_paths_like(@appending_directory, :relative_to => @root)
    end

    it "returns an IMW resource when appending" do
      @archive.append(*Dir[@appending_directory + "/**/*"]).class.should == IMW::Resource
    end
  end
  

  it "can extract files which match the original ones it archived" do
    @archive.create(*Dir[@initial_directory + "/**/*"])
    FileUtils.cd @extraction_directory do
      @archive.extract
    end
    @initial_directory.should contain_paths_like(@extraction_directory, :given_base => File.join(@root, @extraction_directory, @initial_directory), :to_match_base => File.join(@root, @initial_directory))
  end

end
