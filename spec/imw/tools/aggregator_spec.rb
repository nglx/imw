require File.dirname(__FILE__) + "/../../spec_helper"

describe IMW::Tools::Aggregator do
  before do
    @dir = 'agg_dir'
    FileUtils.mkdir_p(@dir)

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

    @aggregator = IMW::Tools::Aggregator.new @dir
  end
    
  it "should copy regular files to its directory" do
    @aggregator.aggregate *@files
    @aggregator.dir.path.should contain(*@files)
    @files.each { |path| IMW.open(path).exist?.should be_true }
  end

  it "should copy remote files to its archive directory" do
    @aggregator.aggregate *@remote_files
    @aggregator.dir.path.should contain('_index', 'support') # _index from Http#effective_basename on http://www.google.com
  end

  it "should uncompress compressed files to its directory" do
    @aggregator.aggregate *@compressed_files
    @aggregator.dir.path.should     contain('foobar-bz2', 'foobar-gz')
    @aggregator.dir.path.should_not contain(*@compressed_files)
  end
    
  it "should copy the content of archive files to its archive directory (but not the actual archives)" do
    @aggregator.aggregate *@archives
    @archives.each do |archive|
      @aggregator.dir.path.should_not contain(archive)
      @aggregator.dir.path.should     contain(*IMW.open(archive).contents)
    end
  end
  
end


