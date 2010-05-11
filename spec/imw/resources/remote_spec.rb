require File.join(File.dirname(__FILE__),'../../spec_helper')

describe IMW::Resources::RemoteObj do
end

describe IMW::Resources::RemoteFile do

  before { @file = IMW.open('http://www.google.com') }

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
