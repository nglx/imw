require File.join(File.dirname(__FILE__),'../../spec_helper')

describe IMW::Schemes::Local::Base do

  it "should not extend a local file with LocalDirectory" do
    @file = IMW::Resource.new('foo.txt', :no_modules => true)
    @file.should_not_receive(:extend).with(IMW::Schemes::Local::LocalDirectory)
    IMW::Resource.extend_instance!(@file)
  end

  it "should not extend a local directory with LocalFile" do
    @dir = IMW::Resource.new(IMWTest::TMP_DIR, :no_modules => true)
    @dir.should_not_receive(:extend).with(IMW::Schemes::Local::LocalFile)
    IMW::Resource.extend_instance!(@dir)
  end

  it "should correctly resolve relative paths" do
    IMW.open('foobar').dirname.should == IMWTest::TMP_DIR
  end

  it "should be able to return its directory as an IMW object" do
    IMW.open('/path/to/file').dir.path.should == '/path/to'
    IMW.open('/').dir.path.should == '/'
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

  it "can produce a snippet" do
    path = IMWTest::DATA_DIR + "/formats/none/sample"
    # FIXME only look at the first 100 bytes b/c of subsequent non-ascii chars...
    IMW.open(path).snippet[0..100].should == File.new(path).read(101)
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

  it "can list its contents as IMW::Resource objects" do
    @dir.resources.map(&:class).uniq.first.should == IMW::Resource
  end

  describe "checking whether it contains other resources" do

    it "should return false for remote paths" do
      @dir.contains?("http://google.com").should be_false
    end

    it "should return true for its own path" do
      @dir.contains?(@dir.path).should be_true
    end

    it "should return false for a path that doesn't start with its path" do
      @dir.contains?(File.expand_path('foo')).should be_false
    end

    it "should return false for a path that starts with its path but doesn't exist" do
      @dir.contains?(File.expand_path('dir/foo/baz')).should be_false
    end

    it "should return true for a path that starts with its path and exists" do
      FileUtils.mkdir_p('dir/foo/baz')
      @dir.contains?(File.expand_path('dir/foo/baz')).should be_true
    end

  end

  describe "handling schemata" do

    it "should recognize a YAML schema file" do
      schemata_path = File.join(@dir.path, 'schema.yaml')
      IMWTest::Random.file(schemata_path)
      @dir.schemata_path.should == schemata_path
    end

    it "should recognize a JSON schema file" do
      schemata_path = File.join(@dir.path, 'schema.json')
      IMWTest::Random.file(schemata_path)
      @dir.schemata_path.should == schemata_path
    end

    it "should recognize a funny-named YAML schema file" do
      schemata_path = File.join(@dir.path, 'schema-1838293.yml')
      IMWTest::Random.file(schemata_path)
      @dir.schemata_path.should == schemata_path
    end
    
  end

  it "can join with a path" do
    @dir.join("a", "b/c").to_s.should == File.join(@dir.path, 'a/b/c')
  end

  it "can create a subdirectory" do
    @dir.join("mallaco").exist?.should be_false
    subdir = @dir.subdir!("mallaco")
    subdir.exist?.should be_true
    subdir.directory?.should be_true
  end
  
  describe 'can package itself to' do
    ['tar', 'tar.bz2', 'tar.gz', 'zip', 'rar'].each do |extension|
      it "a #{extension} archive" do
        @dir.package("package.#{extension}").exist?.should be_true # FIXME should explicitly check paths are correct in archive
      end
    end
  end
end


