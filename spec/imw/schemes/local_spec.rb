require File.join(File.dirname(__FILE__),'../../spec_helper')

describe IMW::Schemes::Local::Base do

  it "should not extend a local file with LocalDirectory" do
    @file = IMW::Resource.new('foo.txt', :skip_modules => true)
    @file.should_not_receive(:extend).with(IMW::Schemes::Local::LocalDirectory)
    @file.extend_appropriately!
  end

  it "should not extend a local directory with LocalFile" do
    @dir = IMW::Resource.new(IMWTest::TMP_DIR, :skip_modules => true)
    @dir.should_not_receive(:extend).with(IMW::Schemes::Local::LocalFile)
    @dir.extend_appropriately!
  end

  it "should correctly resolve relative paths" do
    IMW.open('foobar').dirname.should == IMWTest::TMP_DIR
  end
end

describe IMW::Schemes::Local::LocalFile do
  before do
    IMWTest::Random.file('original.txt')
    @file = IMW::Resource.new('original.txt')
  end

  it "can delete the file" do
    @file.rm
    @file.exist?.should be_false
  end


  it "can read a file" do
    @file.read.size.should > 0
  end

  it "can load the lines of a file" do
    data = @file.load
    data.size.should > 0
    data.class.should == Array
  end

  it "can iterate over the lines of a file" do
    @file.load do |line|
      line.class.should == String
      break
    end
  end

  it "can map the lines of a file" do
    @file.map do |line|
      line[0..5]
    end.class.should == Array
  end
end

describe IMW::Schemes::Local::LocalDirectory do
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

