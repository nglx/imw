module IMW
  module Formats
    autoload :Csv,   'imw/formats/delimited'
    autoload :Tsv,   'imw/formats/delimited'
    autoload :Excel, 'imw/formats/excel'
    autoload :Json,  'imw/formats/json'
    autoload :Xml,   'imw/formats/sgml'
    autoload :Xsl,   'imw/formats/sgml'
    autoload :Html,  'imw/formats/sgml'
    autoload :Xhtml, 'imw/formats/sgml'
    autoload :Rdf,   'imw/formats/sgml'      
    autoload :Yaml,  'imw/formats/yaml'

    # Handlers which augment a resource with data format specific
    # methods.
    HANDLERS = [
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


