require File.join(File.dirname(__FILE__),'../../spec_helper')

describe IMW::Formats::Xml do
  # just spec Xml now as the others are identical

  before do
    @sample = IMW.open(File.join(IMWTest::DATA_DIR, 'formats/sgml/sample.xml'))
  end

  it "should be able to load the XML" do
    ((@sample.load/"genus").first/"name").first.inner_text.should == 'Mandrillus'
  end

  it "should yield the XML when load is given a block" do
    @sample.load do |xml|
      ((xml/"genus").first/"name").first.inner_text.should == 'Mandrillus'
    end
  end

  it "should parse the XML" do
    @sample.parse(:species => ['species[@id]'])[:species].size.should == 130
  end
end

