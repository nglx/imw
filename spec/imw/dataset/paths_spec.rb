require File.dirname(__FILE__) + "/../../spec_helper"
require File.dirname(__FILE__) + "/../utils/shared_paths_spec"

describe IMW::Dataset do

  describe 'setting default paths' do

    before do
      @dataset = IMW::Dataset.new(:testing, :root => IMWTest::TMP_DIR)
    end

    it "should set its root path to the value given" do
      @dataset.path_to(:root).should == IMWTest::TMP_DIR
    end

    it "should set paths for each workflow dir" do
      @dataset.workflow_dirs.each do |dir|
        @dataset.path_to(dir).should == File.join(IMWTest::TMP_DIR, dir.to_s)
      end
    end

    before do
      @path_manager = @dataset
    end
    it_should_behave_like "an object that manages paths"
    
  end
end




