require File.dirname(__FILE__) + "/../../spec_helper"

describe IMW::Metadata::ContainsMetadata do

  before do
    class Foo
      attr_accessor :contents
      def path     ;  IMWTest::TMP_DIR ; end
      def basename ;  File.basename(IMWTest::TMP_DIR) ; end
      include IMW::Metadata::ContainsMetadata
    end
    @foo = Foo.new
    @foo.contents = []
  end

  describe 'finding the default metadata URI' do
    it "should return the default metadata URI when 'contents' is empty" do
      @foo.default_metadata_uri.should == File.join(IMWTest::TMP_DIR, File.basename(IMWTest::TMP_DIR) + ".icss.yaml")
    end

    it "should return the default metadata URI when 'contents' doesn't contain any metadata files" do
      @foo.contents.concat ['bar.txt', 'crazy_file.yaml', 'foo.json'].map { |p| File.join(IMWTest::TMP_DIR, p) }
      @foo.default_metadata_uri.should == File.join(IMWTest::TMP_DIR, File.basename(IMWTest::TMP_DIR) + ".icss.yaml")
    end

    %w[my-projects.icss.yaml stupid-crazy-fool-of-a-dataset-icss.json foobar-25.metadata.buzz.yml].each do |basename|
      it "should return the metadata URI when 'contents' contains a URI matching '#{basename}'" do
        @foo.contents.concat ['bar.txt', 'crazy_file.yaml', 'foo.json', basename].map { |p| File.join(IMWTest::TMP_DIR, p) }
        @foo.default_metadata_uri.should == File.join(IMWTest::TMP_DIR, basename)
      end
    end
  end


  describe 'returning its metadata' do
    it "should return 'nil' when no metadata exists on disk" do
      @foo.metadata.should be_nil
    end

    it "should return Metadata when metadata exists on disk" do
      IMW.open!(@foo.default_metadata_uri) do |f|
        f.write <<YAML
---
foo:
  description: bar
  fields: baz
YAML
      end
      @foo.metadata.class.should == IMW::Metadata
      @foo.metadata['foo']['description'].should == 'bar'
    end
  end
  
  

end
