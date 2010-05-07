require File.join(File.dirname(__FILE__),'../../spec_helper')

describe IMW::Resources::RemoteObj do
end

describe IMW::Resources::RemoteFile do

  before { @file = IMW.open('http://www.google.com') }

  describe 'on the filesystem' do

    it "can copy a remote file to a path on the local filesystem" do
      @file.cp('google.html')
      IMWTest::TMP_DIR.should contain('google.html')
    end

    it "can copy a remote file to a directory on the local filesystem" do
      @file.cp_to_dir(IMWTest::TMP_DIR)
      IMWTest::TMP_DIR.should contain('_index') # see IMW::Resources::Schems::HTTP
    end
  end

  describe 'with the file' do

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
