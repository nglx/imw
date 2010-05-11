module IMW
  module Resources
    module Formats
      autoload :Csv,   'imw/resources/formats/delimited'
      autoload :Tsv,   'imw/resources/formats/delimited'
      autoload :Excel, 'imw/resources/formats/excel'
      autoload :Json,  'imw/resources/formats/json'
      autoload :Xml,   'imw/resources/formats/sgml'
      autoload :Xsl,   'imw/resources/formats/sgml'
      autoload :Html,  'imw/resources/formats/sgml'
      autoload :Xhtml, 'imw/resources/formats/sgml'
      autoload :Rdf,   'imw/resources/formats/sgml'      
      autoload :Yaml,  'imw/resources/formats/yaml'

      # Handlers which augment a resource with data format specific
      # methods.
      FORMAT_HANDLERS = [
                         [ "Formats::Csv",   /\.csv$/    ],
                         [ "Formats::Tsv",   /\.tsv$/    ],
                         [ "Formats::Excel", /\.xslx?$/  ],
                         [ "Formats::Json",  /\.json$/   ],
                         [ "Formats::Xml",   /\.xml$/    ],
                         [ "Formats::Xsl",   /\.xsl$/    ],                         
                         [ "Formats::Html",  /\.html?$/  ],
                         [ "Formats::Xhtml", /\.xhtml?$/ ],
                         [ "Formats::Rdf",   /\.rdf?$/   ],
                         [ "Formats::Yaml",  /\.ya?ml$/  ]
                        ]
    end
  end
end

