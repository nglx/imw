require File.join(File.dirname(__FILE__),'../../spec_helper')

describe IMW::Schemes::HDFS do
  before do
    def fake_hdfs_resource path, options={}
      if options == false
        response = ""
      else        
        response = "           #{options[:dirs] || 0}            #{options[:files] || 1}              #{options[:size] || 1000} hdfs://localhost#{path}"
      end
      IMW::Schemes::HDFS.should_receive(:fs).with(:count, path).at_least(:once).and_return(response)
      IMW.open("hdfs://#{path}")
    end
    @path = '/path/to/myfile'    
  end
  
  describe "refreshing its properties" do
    it "should correctly get properties for a resource which exists" do
      resource = fake_hdfs_resource(@path, :dirs => 2, :files => 3, :size => 1000)
      resource.exist?.should    be_true
      resource.num_dirs.should  == 2
      resource.num_files.should == 3
      resource.size.should      == 1000
    end

    it "should gracefully handle a resource which doesn't exist" do
      resource = fake_hdfs_resource(@path, false)
      resource.exist?.should be_false
    end

    it "should execute the correct command to delete the path" do
      resource = fake_hdfs_resource(@path)
      IMW::Schemes::HDFS.should_receive(:fs).with(:rm, resource.path)
      resource.rm
    end

    it "should execute the correct command to delete the path when skipping the trash" do
      resource = fake_hdfs_resource(@path)
      IMW::Schemes::HDFS.should_receive(:fs).with(:rm, '-skipTrash', resource.path)
      resource.rm :skip_trash => true
    end

    it "should recognize a file and extend it properly" do
      resource = fake_hdfs_resource(@path)
      resource.num_dirs.should == 0      
      resource.num_files.should == 1
      resource.exist?.should be_true
      resource.is_directory?.should be_false
      resource.modules.should include(IMW::Schemes::HDFSFile)
    end

    it "should recognize a directory and extend it properly" do
      resource = fake_hdfs_resource(@path, :dirs => 2, :files => 1)
      resource.num_dirs.should == 2
      resource.num_files.should == 1
      resource.exist?.should be_true
      resource.is_directory?.should be_true
      resource.modules.should include(IMW::Schemes::HDFSDirectory)
    end

    it "should be able to join path segments to a directory" do
      resource     = fake_hdfs_resource(@path, :dirs => 2)
      sub_resource = fake_hdfs_resource("#{@path}/a/b/c")
      resource.join('a', 'b/c').to_s.should == sub_resource.to_s
    end
  end
end
