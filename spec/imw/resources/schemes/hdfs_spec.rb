require File.join(File.dirname(__FILE__),'../../../spec_helper')

describe IMW::Resources::Schemes::HDFS do
  before do
    def fake_hdfs_resource path, num_dirs=nil, num_files=nil, size=nil
      if num_dirs && num_files && size
        response = "           #{num_dirs}            #{num_files}              #{size} hdfs://localhost#{path}"
      else
        response = ""
      end
      IMW::Resources::Schemes::HDFS.should_receive(:fs).with(:count, path).and_return(response)
      IMW.open("hdfs://#{path}")
    end
    @path = '/path/to/myfile'    
  end
  
  describe "refreshing its properties" do
    it "should correctly get properties for a resource which exists" do
      resource = fake_hdfs_resource(@path, 2, 3, 1000)
      resource.exist?.should    be_true
      resource.num_dirs.should  == 2
      resource.num_files.should == 3
      resource.size.should      == 1000
    end

    it "should gracefully handle a resource which doesn't exist" do
      resource = fake_hdfs_resource(@path)
      resource.exist?.should be_false
    end

    it "should execute the correct command to delete the path" do
      resource = fake_hdfs_resource(@path, 2, 3, 1000)
      IMW::Resources::Schemes::HDFS.should_receive(:fs).with(:rm, resource.path)
      resource.rm
    end

    it "should execute the correct command to delete the path when skipping the trash" do
      resource = fake_hdfs_resource(@path, 2, 3, 1000)      
      IMW::Resources::Schemes::HDFS.should_receive(:fs).with(:rm, '-skipTrash', resource.path)
      resource.rm :skip_trash => true
    end

    it "should recognize a file and extend it properly" do
      resource = fake_hdfs_resource(@path, 0, 1, 1000)
      resource.num_dirs.should == 0      
      resource.num_files.should == 1
      resource.exist?.should be_true
      resource.is_directory?.should be_false
      resource.resource_modules.should include(IMW::Resources::Schemes::HDFSFile)
    end

    it "should recognize a directory and extend it properly" do
      resource = fake_hdfs_resource(@path, 2, 1, 1000)
      resource.num_dirs.should == 2
      resource.num_files.should == 1
      resource.exist?.should be_true
      resource.is_directory?.should be_true
      resource.resource_modules.should include(IMW::Resources::Schemes::HDFSDirectory)
    end
  end
end
