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
    autoload :Pdf,   'imw/formats/pdf'

    # Handlers which augment a resource with data format specific
    # methods.
    HANDLERS = [
                [ "Formats::Csv",   /\.csv$/i    ],
                [ "Formats::Tsv",   /\.tsv$/i    ],
                [ "Formats::Excel", /\.xlsx?$/i  ],
                [ "Formats::Json",  /\.json$/i   ],
                [ "Formats::Xml",   /\.xml$/i    ],
                [ "Formats::Xsl",   /\.xsl$/i    ],                         
                [ "Formats::Html",  /\.html?$/i  ],
                [ "Formats::Xhtml", /\.xhtml?$/i ],
                [ "Formats::Rdf",   /\.rdf?$/i   ],
                [ "Formats::Yaml",  /\.ya?ml$/i  ],
                [ "Formats::Pdf",   /\.pdf$/i    ]
               ]
  end
end


