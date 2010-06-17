require File.dirname(__FILE__) + "/../../spec_helper"

describe IMW::Tools::Transferer do
  before do
    @dir     = IMW.open("dir")
    @new_dir = IMW.open("new_dir")
    @nested  = IMW.open('new_dir/nested.txt')
    @nested_dir = IMW.open('new_dir/nested')
    @local   = IMW.open("foobar.txt")
    @dest    = IMW.open("barbaz.txt")
    @http    = IMW.open("http://www.google.com")
    @hdfs    = IMW.open("hdfs:///path/to/foobar.txt")
    @s3      = IMW.open("s3://mybucket/foo/bar")
    IMWTest::Random.file(@local.path)
  end

  it "should raise an error unless the action is one of :cp, :copy, :mv :move, or :mv!" do
    @transferer = IMW::Tools::Transferer.new(:cp, @local, @http)
    @transferer.action = :cp
    @transferer.action = :copy
    @transferer.action = :mv
    @transferer.action = :mv!    
    @transferer.action = :move
    lambda { @transferer.action = :foobar }.should raise_error(IMW::ArgumentError)
  end

  it "should raise an error if the source and the destination have the same URI" do
    lambda { IMW::Tools::Transferer.new(:cp, @local, @local) }.should raise_error(IMW::PathError)
  end

  it "should print a log message when IMW is verbose" do
    IMW.stub!(:verbose).and_return(:true)
    IMW.should_receive(:announce_if_verbose).with("Copying #{@local} to #{@dest}")
    IMW::Tools::Transferer.new(:cp, @local, @dest).transfer!
  end
  
  describe "transfering local files" do

    before do
      IMWTest::Random.file @local.path
      @transferer = IMW::Tools::Transferer.new(:cp, @local, @dest)
    end
    
    it "should raise an error if the source doesn't exist" do
      @local.rm!
      lambda { @transferer.source = @local }.should raise_error(IMW::PathError)
    end

    it "should raise an error if the directory of the destination doesn't exist" do
      lambda { @transferer.destination = @nested }.should raise_error(IMW::PathError)
    end

    it "can copy a local file" do
      @transferer.transfer!
      @local.exist?.should be_true
      @dest.exist?.should  be_true
    end

    it "can copy a local file to a directory" do
      FileUtils.mkdir(@dir.path)
      @transferer.destination = @dir
      @transferer.transfer!
      IMW.open(File.join(@dir.path, @local.basename)).exist?.should be_true
    end

    it "can move a local file" do
      @transferer.action = :mv
      @transferer.transfer!
      @local.exist?.should be_false
      @dest.exist?.should  be_true
    end

    it "can move a local file to a directory" do
      FileUtils.mkdir(@dir.path)
      @transferer.action = :mv
      @transferer.destination = @dir
      @transferer.transfer!
      IMW.open(File.join(@dir.path, @local.basename)).exist?.should be_true
      @local.exist?.should be_false
    end
  end

  describe "transfering local directories" do

    before do
      IMWTest::Random.directory_with_files @dir.path
      @dir = @dir.reopen
    end
    
    it "should raise an error if the source doesn't exist" do
      @dir.rm_rf!
      lambda { IMW::Tools::Transferer.new(:cp, @dir, @new_dir).transfer! }.should raise_error(IMW::PathError)
    end

    it "should raise an error if the directory of the destination doesn't exist" do
      lambda { IMW::Tools::Transferer.new(:cp, @dir, @nested_dir).transfer! }.should raise_error(IMW::PathError)
    end

    it "can copy a local directory" do
      IMW::Tools::Transferer.new(:cp, @dir, @new_dir).transfer!
      @dir.exist?.should be_true
      @new_dir.exist?.should be_true
    end

    it "can move a local directory" do
      IMW::Tools::Transferer.new(:mv, @dir, @new_dir).transfer!
      @dir.exist?.should be_false
      @new_dir.exist?.should be_true
    end

    it "can copy a local directory to an existing directory" do
      FileUtils.mkdir(@new_dir.path)
      IMW::Tools::Transferer.new(:cp, @dir, @nested_dir).transfer!
      @dir.exist?.should be_true
      @nested_dir.exist?.should be_true
    end

    it "can move a local directory to an existing directory" do
      FileUtils.mkdir(@new_dir.path)
      IMW::Tools::Transferer.new(:mv, @dir, @nested_dir).transfer!
      @dir.exist?.should_not be_true
      @nested_dir.exist?.should be_true
    end
  end
  

  describe "transferring HTTP files" do
    it "can copy a remote file to a local path" do
      IMW::Tools::Transferer.new(:cp, @http, @local).transfer!
      @local.exist?.should be_true
    end
  end

  describe "transferring S3 files" do

    it "can copy an S3 file to a local path" do
      IMW::Schemes::S3.should_receive(:get).with(@s3, @local)
      IMW::Tools::Transferer.new(:cp, @s3, @local).transfer!
    end

    it "can copy a local path to an S3 file" do
      IMWTest::Random.file @local.path
      IMW::Schemes::S3.should_receive(:put).with(@local, @s3)
      IMW::Tools::Transferer.new(:cp, @local, @s3).transfer!
    end

    it "can copy between S3 files" do
      @new_s3 = IMW.open('s3://mybucket/new/path')
      IMW::Schemes::S3.should_receive(:copy).with(@s3, @new_s3)
      IMW::Tools::Transferer.new(:cp, @s3, @new_s3).transfer!
    end
  end

  describe "transferring HDFS files" do
    before do
      IMW::Schemes::HDFS.stub!(:fs)
    end

    it "can copy a local file to an HDFS path" do
      IMWTest::Random.file @local.path

      IMW::Schemes::HDFS.should_receive(:fs).with(:put, @local.path, @hdfs.path)
      IMW::Tools::Transferer.new(:cp, @local, @hdfs).transfer!
    end

    it "can copy an HDFS file to a local path" do
      IMW::Schemes::HDFS.should_receive(:fs).with(:get, @hdfs.path, @local.path)
      IMW::Tools::Transferer.new(:cp, @hdfs, @local).transfer!
    end

    it "can copy between HDFS paths" do
      @new_hdfs = IMW.open('hdfs:///a/new/path')
      IMW::Schemes::HDFS.should_receive(:fs).with(:cp, @hdfs.path, @new_hdfs.path)
      IMW::Tools::Transferer.new(:cp, @hdfs, @new_hdfs).transfer!
    end

    it "can move between HDFS paths" do
      @new_hdfs = IMW.open('hdfs:///a/new/path')
      IMW::Schemes::HDFS.should_receive(:fs).with(:mv, @hdfs.path, @new_hdfs.path)
      IMW::Tools::Transferer.new(:mv, @hdfs, @new_hdfs).transfer!
    end

    it "can copy from S3 to HDFS" do
      IMW::Schemes::HDFS.should_receive(:fs).with(:cp, @s3.s3n_url, @hdfs.path)
      IMW::Tools::Transferer.new(:cp, @s3, @hdfs).transfer!
    end

    it "can copy from HDFS to S3" do
      IMW::Schemes::HDFS.should_receive(:fs).with(:cp, @hdfs.path, @s3.s3n_url)
      IMW::Tools::Transferer.new(:cp, @hdfs, @s3).transfer!
    end
  end
end


