module IMW
  module Schemes
    autoload :Local,  'imw/schemes/local'
    autoload :Remote, 'imw/schemes/remote'
    autoload :S3,     'imw/schemes/s3'
    autoload :HTTP,   'imw/schemes/http'
    autoload :HTTPS,  'imw/schemes/http'
    autoload :HDFS,   'imw/schemes/hdfs'
    
    HANDLERS = [
                ["Schemes::Local::Base",  Proc.new { |resource| resource.scheme == 'file' || resource.scheme.blank?    } ],
                ["Schemes::Remote::Base", Proc.new { |resource| resource.scheme != 'file' && resource.scheme.present?  } ],
                ["Schemes::S3",        %r{^s3://}i    ],
                ["Schemes::HTTP",      %r{^http://}i  ],
                ["Schemes::HTTPS",     %r{^https://}i ],
                ["Schemes::HDFS",      %r{^hdfs://}i  ]
               ]
  end
end


