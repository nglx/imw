require File.join(File.dirname(__FILE__),'../../spec_helper')

describe IMW::Formats::Yaml do

  before do
    @sample = IMW.open(File.join(IMWTest::DATA_DIR, 'formats/yaml/sample.yaml')).load
  end

  it "should be able to parse the YAML" do
    @sample['Lophocebus'].first[:id].should == 94
  end

  it "should be able to write YAML" do
    data = { 'foobar' => 3, 'bazbooz' => 4 }
    IMW.open!('test.yaml').emit(data)
    IMW.open('test.yaml').load['foobar'].should == 3
  end
  
end
