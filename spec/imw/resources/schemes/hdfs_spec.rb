require File.join(File.dirname(__FILE__),'../../../spec_helper')

describe IMW::Resources::Schemes::HDFS do
  
  describe "talking to hadoop" do
    before do
      @resource = IMW.open('hdfs:///path/to/myfile')
    end

    it "should execute the correct command to test the path's existence" do
      IMW::Resources::Schemes::HDFS.should_receive(:fs).with(:ls, @resource.dirname).and_yield("drwxr-xr-x   - dhruv supergroup          0 2010-05-08 20:41 /path/to/myfile")
      @resource.exist?.should be_true
    end

    it "should execute the correct command to calculate the path's size" do
      IMW::Resources::Schemes::HDFS.should_receive(:fs).with(:du, @resource.path).and_yield("Found 2 items","100000         hdfs://localhost/data/test/text")
      @resource.size.should == 100000
    end

    it "should execute the correct command to delete the path" do
      IMW::Resources::Schemes::HDFS.should_receive(:fs).with(:rm, @resource.path)
      @resource.rm
    end

    it "should execute the correct command to delete the path when skipping the trash" do
      IMW::Resources::Schemes::HDFS.should_receive(:fs).with(:rm, '-skipTrash', @resource.path)
      @resource.rm :skip_trash => true
    end

  end

end
