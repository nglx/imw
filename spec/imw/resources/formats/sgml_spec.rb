require File.join(File.dirname(__FILE__),'../../../spec_helper')

describe IMW::Resources::Formats::Xml do
  # just spec Xml now as the others are identical

  before do
    @sample = IMW.open(File.join(IMWTest::DATA_DIR, 'sample.xml'))
  end

  it "should be able to load the XML" do
    ((@sample.load/"monkey").first/"genus").inner_text.should == 'Aotus'
  end

  it "should yield the XML when load is given a block" do
    @sample.load do |xml|
      ((xml/"monkey").first/"genus").inner_text.should == 'Aotus'
    end
  end

  it "should parse the XML" do
    @sample.parse(:monkeys => ['monkey'])[:monkeys].size.should == 130
  end
end

