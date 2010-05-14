require File.dirname(__FILE__) + "/../../spec_helper"

describe IMW::Tools::Transferer do
  before do
    @local  = IMW.open("foobar.txt")
    @http   = IMW.open("http://www.google.com")
    @hdfs   = IMW.open("hdfs:///path/to/foobar.txt")
    @s3     = IMW.open("s3://mybucket/foo/bar")
  end

  it "should raise an error unless the action is one of :cp, :copy, :mv :move, or :mv!" do
    IMW::Tools::Transferer.new(:cp,   @local, @http).should be
    IMW::Tools::Transferer.new(:copy, @local, @http).should be
    IMW::Tools::Transferer.new(:mv,   @local, @http).should be
    IMW::Tools::Transferer.new(:move, @local, @http).should be
    IMW::Tools::Transferer.new(:mv!,  @local, @http).should be
    lambda { IMW::Tools::Transferer.new(:foobar, @local, @http) }.should raise_error(IMW::ArgumentError)
  end

  it "should raise an error if the source and the destination have the same URI" do
    lambda { IMW::Tools::Transferer.new(:cp, @local, @local) }.should raise_error(IMW::PathError)
  end

  describe "transfering local files" do
    it "should raise an error if the source doesn't exist" do
      lambda { IMW::Tools::Transferer.new(:cp, @local, 'barbaz.txt').transfer! }.should raise_error(IMW::PathError)
    end

    it "can copy a local file" do
      IMWTest::Random.file @local.path
      IMW::Tools::Transferer.new(:cp, @local, 'barbaz.txt').transfer!
      @local.exist?.should be_true
      IMW.open('barbaz.txt').exist?.should be_true
    end

    it "can move a local file" do
      IMWTest::Random.file @local.path 
      IMW::Tools::Transferer.new(:mv, @local, 'barbaz.txt').transfer!
      @local.exist?.should be_false
      IMW.open('barbaz.txt').exist?.should be_true
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


