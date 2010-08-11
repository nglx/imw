module IMW

  # A collection of classes for describing the metadata associated
  # with a dataset's fields.
  module Metadata
    autoload :Field,       'imw/metadata/field'
    autoload :Schema,      'imw/metadata/schema'
    autoload :Schemata,    'imw/metadata/schemata'
    autoload :Schematized, 'imw/metadata/schematized'
  end
  
end
