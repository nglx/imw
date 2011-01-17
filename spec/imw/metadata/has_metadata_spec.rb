require File.dirname(__FILE__) + "/../../spec_helper"

describe IMW::Metadata::HasMetadata do

  before do
    class Foo
      def uri ; File.join(IMWTest::TMP_DIR, 'test', 'subdir', 'foobar.csv') ; end
      def basename ; File.basename(uri) ; end
      def extension ; 'csv' ; end
      def dir ; IMW.open(File.join(IMWTest::TMP_DIR, 'test', 'subdir')) ; end
      include IMW::Metadata::HasMetadata
    end
    @foo = Foo.new
  end

  it "should be able to build a schema" do
    @foo.schema.should include(:type, :namespace, :name, :doc, :fields, :non_avro)
  end
  
  describe "finding its metadata" do

    before do
      FileUtils.mkdir_p(@foo.dir.path)
      IMWTest::Random.file(File.join(@foo.dir.path, 'foobar.csv'))
    end

    it "should return 'nil' when it can't find any metadata" do
      @foo.metadata.should be_nil
    end

    it "should return 'nil' when a metadata file is found that doesn't describe it" do
      IMW.open!("schematized_test.icss.yaml") do |f|
        f.write <<YAML
---
foobar.csv:
  description: bar
  fields: ["baz", "booz"]
YAML
      end
      @foo.metadata.should be_nil
    end

    it "should return the metadata when a metadata file is found that does describe it" do
      IMW.open!("schematized_test.icss.yaml") do |f|
        f.write <<YAML
---
test/subdir/foobar.csv:
  description: bar
  fields: ["baz", "booz"]
YAML
      end
      @foo.metadata.class.should == IMW::Metadata
      @foo.metadata[@foo]['description'].should == 'bar'
    end
    
  end
  
end
