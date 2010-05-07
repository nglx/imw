module IMW
  module Resources
    autoload :Compressible,    'imw/resources/compressible'
    autoload :CompressedFile,  'imw/resources/compressed_file'
    autoload :Archive,         'imw/resources/archive'
    autoload :Archives,        'imw/resources/archive'
    autoload :CompressedFiles, 'imw/resources/compressed_file'

    # Handlers which augment the resource with methods for archiving,
    # extracting, compressing, decompressing...
    ARCHIVE_AND_COMPRESSED_HANDLERS = [

                                       # try compressible first -- compressed files below will override it
                                       ["Compressible",         Proc.new { |r| r.local? } ],

                                       # order is important! -- tar.bz2 must come before .bz2, &c.
                                       ["Archives::Tarbz2",     Proc.new { |r| r.local? && r.path =~ /\.tar\.bz2$/                                              } ],
                                       ["Archives::Tarbz2",     Proc.new { |r| r.local? && r.path =~ /\.tbz2$/                                                  } ],
                                       ["CompressedFiles::Bz2", Proc.new { |r| r.local? && r.path =~ /\.bz2$/ && r.path !~ /\.tar\.bz2$/ && r.path !~ /\.tbz2$/ } ],
                                       ["Archives::Targz",      Proc.new { |r| r.local? && r.path =~ /\.tar\.gz$/                                               } ],
                                       ["Archives::Targz",      Proc.new { |r| r.local? && r.path =~ /\.tgz$/                                                   } ],
                                       ["CompressedFiles::Gz",  Proc.new { |r| r.local? && r.path =~ /\.gz$/  && r.path !~ /\.tar\.gz$/  && r.path !~ /\.tgz$/  } ],
                                       ["Archives::Tar",        Proc.new { |r| r.local? && r.path =~ /\.tar$/                                                   } ],
                                       ["Archives::Rar",        Proc.new { |r| r.local? && r.path =~ /\.rar$/                                                   } ],
                                       ["Archives::Zip",        Proc.new { |r| r.local? && r.path =~ /\.zip$/                                                   } ]

                                      ]

    
  end
end
    
