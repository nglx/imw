require File.dirname(__FILE__) + "/../../spec_helper"

describe IMW::Transforms::Archiver do
  before do
    @name = 'foobar'

    # remote files
    @homepage = "http://www.google.com"
    @website  = "http://www.google.com/support/"
    @remote_files = [@homepage, @website]

    # regular files
    @csv  = "foobar-csv.csv"
    @xml  = "foobar-xml.xml"
    @txt  = "foobar-txt.txt"
    @blah = "foobar"
    @files = [@csv, @xml, @txt, @blah]

    # compressed files
    @bz2  = "foobar-bz2.bz2"
    @gz   = "foobar-gz.gz"
    @compressed_files = [@bz2, @gz]

    # archives
    @zip      = "foobar-zip.zip"
    @tarbz2   = "foobar-tarbz2.tar.bz2"
    @targz    = "foobar-targz.tar.gz"
    @tar      = "foobar-tar.tar"
    @rar      = "foobar-rar.rar"
    @archives = [@zip, @tarbz2, @targz, @rar, @tar]

    @local_files = @files + @compressed_files + @archives

    @all_files = @remote_files + @local_files
    
    @local_files.each do |path|
      IMWTest::Random.file path
    end

    @archiver = IMW::Transforms::Archiver.new @name, @all_files
  end

  after do
    @archiver.clean!
  end
  
  describe "preparing input files" do
    
    describe "before preparing input files" do
      it "should not be prepared when initialized" do
        @archiver.prepared?.should be_false
      end
    end

    describe "after preparing files" do
      before { @archiver.prepare! }

      it "should be prepared" do
        @archiver.prepared?.should be_true
      end

      it "should name its archive directory properly" do
        @archiver.tmp_dir.should contain(@name)
      end
      
      it "should copy regular files to its archive directory" do
        @archiver.dir.should contain(*@files)
        @local_files.each { |path| IMW.open(path).exist?.should be_true }
      end

      it "should copy remote files to its archive directory" do
        @archiver.dir.should contain('_index', 'support') # _index from Http#effective_basename on http://www.google.com
      end

      it "should uncompress compressed files to its archive directory" do
        @archiver.dir.should     contain('foobar-bz2', 'foobar-gz')
        @archiver.dir.should_not contain(*@compressed_files)
      end
      
      it "should copy the content of archive files to its archive directory (but not the actual archives)" do
        @archives.each do |archive|
          @archiver.dir.should_not contain(archive)
          @archiver.dir.should     contain(*IMW.open(archive).contents)
        end
      end

    end
  end
  
  describe "when packaging files" do
    @packages = ["package.tar.bz2", "package.zip", "package.tar.gz", "package.tar", "package.rar"]

    @packages.each do |package|    
      it "should create a #{package} file containing all the files and return it" do
        output = @archiver.package!(package)
        output.basename.should == package
        @archiver.tmp_dir.should contain(IMW.open(package).contents)
      end
    end

    describe 'when packaging into multiple output formats' do

      it "should prepare input files without being asked" do
        @archiver.prepared?.should be_false
        @archiver.package! 'package.tar.bz2'
        @archiver.prepared?.should be_true
      end
      
      it "should not prepare input files once they've already been prepared" do
        @archiver.prepared?.should be_false
        @archiver.package! 'package.tar.bz2'
        @archiver.prepared?.should be_true        
        @archiver.should_not_receive(:prepare!)
        @archiver.package! 'package.tar.gz'
      end
    end
  end
end


