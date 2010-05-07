require File.join(File.dirname(__FILE__),'../../../spec_helper')

describe IMW::Resources::Formats::Yaml do

  before do
    @sample = IMW.open(File.join(IMWTest::DATA_DIR, 'sample.yaml'))
  end

  it "should be able to parse the YAML" do
    @sample.load['monkeys'].first['monkey']['id'].should == 1
  end

  it "should be able to write YAML" do
    data = { 'foobar' => 3, 'bazbooz' => 4 }
    IMW.open!('test.yaml').dump(data)
    IMW.open('test.yaml').load['foobar'].should == 3
  end
  
  it "should yield each key and value when the YAML is a hash and it's given a block" do
    @sample.load do |key, value|
      value.size.should == 130
    end
  end

  it "should yield each element when the YAML is an array and it's given a block" do
    IMW.open!('test.yaml').dump([1,2,3])
    num = 1
    IMW.open('test.yaml').load do |parsed_num|
      parsed_num.should == num
      num +=1
    end
  end

  it "should yield a string when the YAML is a string and it's given a block" do
    IMW.open!('test.yaml').dump('foobar')
    IMW.open('test.yaml').load do |string|
      string.should == 'foobar'
    end
  end
  
end
