require File.join(File.dirname(__FILE__),'../../spec_helper')

describe IMW::Resources::LocalObj do

  it "should not extend a local file with LocalDirectory" do
    @file = IMW::Resource.new('foo.txt', :skip_modules => true)
    @file.should_not_receive(:extend).with(IMW::Resources::LocalDirectory)
    @file.extend_appropriately!
  end

  it "should not extend a local directory with LocalFile" do
    @dir = IMW::Resource.new(IMWTest::TMP_DIR, :skip_modules => true)
    @dir.should_not_receive(:extend).with(IMW::Resources::LocalFile)
    @dir.extend_appropriately!
  end

  it "should correctly resolve relative paths" do
    IMW.open('foobar').dirname.should == IMWTest::TMP_DIR
  end
end

describe IMW::Resources::LocalFile do
  before do
    IMWTest::Random.file('original.txt')
    @file = IMW::Resource.new('original.txt')
  end

  describe "on the filesystem" do

    it "can copy the file" do
      copy = @file.cp('copy.txt')
      @file.exist?.should be_true
      copy.exist?.should  be_true
    end

    it "can move the file" do
      copy = @file.mv('copy.txt')
      @file.exist?.should be_false
      copy.exist?.should  be_true
    end

    it "can delete the file" do
      @file.rm
      @file.exist?.should be_false
    end

    before do
      FileUtils.mkdir_p('subdir')
    end

    it "can copy to a directory" do
      @file.cp_to_dir('subdir')
      @file.exist?.should be_true
      IMW::Resource.new('subdir').contains?(@file.basename).should be_true
    end

    it "can move to a directory" do
      @file.mv_to_dir('subdir')
      @file.exist?.should be_false
      IMW::Resource.new('subdir').contains?(@file.basename).should be_true
    end
  end

  describe "with a file" do

    it "can read a remote file" do
      @file.read.size.should > 0
    end

    it "can load the lines of a remote file" do
      data = @file.load
      data.size.should > 0
      data.class.should == Array
    end

    it "can iterate over the lines of a remote file" do
      @file.load do |line|
        line.class.should == String
        break
      end
    end

    it "can map the lines of a remote file" do
      @file.map do |line|
        line[0..5]
      end.class.should == Array
    end
  end
end

describe IMW::Resources::LocalDirectory do
  before do
    FileUtils.mkdir_p('dir')
    FileUtils.mkdir_p('dir/subdir')
    FileUtils.cd('dir') do
      IMWTest::Random.file('file1.tsv')
      IMWTest::Random.file('file2.tsv')
      FileUtils.cd('subdir') do
        IMWTest::Random.file('file3.csv')
      end
    end
    @dir = IMW::Resource.new('dir')
  end

  it "can copy the directory" do
    FileUtils.mkdir('copy')
    copy = @dir.cp('copy')
    @dir.exist?.should be_true
    copy.exist?.should be_true
  end

  it "can move the directory" do
    FileUtils.mkdir('copy')
    copy = @dir.mv('copy')
    @dir.exist?.should be_false
    copy.exist?.should be_true
  end

  it "can delete an empty directory" do
    FileUtils.mkdir('empty')
    dir = IMW.open('empty')
    dir.rmdir
    dir.exist?.should be_false
  end

  it "can recursively delete a directory" do
    @dir.rm_rf
    @dir.exist?.should be_false
  end

  before do
    FileUtils.mkdir_p('subdir')
  end

  it "can copy to a directory" do
    @dir.cp_to_dir('subdir')
    @dir.exist?.should be_true
    IMW::Resource.new('subdir').contains?(@dir.basename).should be_true
  end

  it "can move to a directory" do
    @dir.mv_to_dir('subdir')
    @dir.exist?.should be_false
    IMW::Resource.new('subdir').contains?(@dir.basename).should be_true
  end

  it "can list its contents" do
    @dir.contents.size.should == 3
  end

  it "can list its contents recursively" do
    @dir.all_contents.size.should == 4
  end

  it "can list its contents recursively as IMW::Resource objects" do
    @dir.resources.map(&:class).uniq.first.should == IMW::Resource
  end

end

  
