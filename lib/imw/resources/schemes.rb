module IMW
  module Resources
    module Schemes
      autoload :S3,    'imw/resources/schemes/s3'
      autoload :HTTP,  'imw/resources/schemes/http'
      autoload :HTTPS, 'imw/resources/schemes/http'
      autoload :HDFS,  'imw/resources/schemes/hdfs'

      # Handlers which extend a resource with scheme specific methods.
      SCHEME_HANDLERS = [
                         ["Schemes::S3",    %r{^s3://}    ],
                         ["Schemes::HTTP",  %r{^http://}  ],
                         ["Schemes::HTTPS", %r{^https://} ],
                         ["Schemes::HDFS",  %r{^hdfs://}  ]
                        ]
    end
  end
end

