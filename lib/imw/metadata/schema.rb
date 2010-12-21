module IMW
  class Metadata
    
    # A class to describe the schema of a resource.
    #
    # A Schema is built on top of an Array because it is often
    # important to have an ordering for a record's fields.
    #
    # For fields with no such ordering, an Array also works because
    # each of its element will be a field with a +name+ that can be
    # used to index the corresponding field.
    #
    # A Schema is instantiated with a basic Ruby data structure.
    #
    # == Tabular Data
    #
    # Tabular data formats (CSV, TSV, &c.) contain flat records
    # consisting of repeating rows with the same fields in the same
    # position.  A sample of delimited data looks like
    #
    #   ID,Name,Genus,Species					   
    #   001,Gray-bellied Night Monkey,Aotus,lemurinus		   
    #   002,Panamanian Night Monkey,Aotus,zonalis		   
    #   003,Hernández-Camacho's Night Monkey,Aotus,jorgehernandezi 
    #   004,Gray-handed Night Monkey,Aotus,griseimembra		   
    #   005,Hershkovitz's Night Monkey,Aotus,hershkovitzi
    #   ...
    #
    # The schema of these records is summarized as a Ruby data
    # structure in the following way
    #
    #   [
    #     { :name => :id,      :type => :integer                         },
    #     { :name => :name,    :type => :string, :title => "Common Name" },
    #     { :name => :genus,   :type => :string, :title => "Genus"       },
    #     { :name => :species, :type => :string, :title => "Species"     }
    #   ]
    #
    # The outer-most Array represents each row and each Hash in the
    # Array represents one of the fields in a row.  A Schema
    # initialized with the above Ruby code can be thought of and
    # played with as an Array of Hashes even though it really is a
    # Schema object of Field objects.
    #
    # == Hierarchical Data
    #
    # Hierarchical data formats (JSON, YAML, XML, &c.) can have
    # arbitrarily complex records with fields within fields and so on.
    # A sample of hierarchical XML data looks like
    #
    #   <genera>				      
    #     <genus>				      
    #       <name>Mandrillus</name>		      
    #       <species>				      
    #         <species id="113">		      
    #           <name>sphinx</name>		      
    #           <common_name>Mandrill</common_name>   
    #         </species>			      
    #         <species id="114">		      
    #           <name>leucophaeus</name>	      
    #           <common_name>Drill</common_name>      
    #         </species>			      
    #       </species>				      
    #     </genus>				      
    #     <genus>				      
    #       <name>Rungwecebus</name>		      
    #       <species>				      
    #         <species id="100">		      
    #           <name>kipunji</name>		      
    #           <common_name>Kipunji</common_name>    
    #         </species>			      
    #       </species>				      
    #     </genus>                                    
    #
    # These records are described by the following Ruby data structure
    #
    #   [
    #     { :name     => :genera,
    #       :has_many => [
    #         { :name => 'name',    :type => :string, title => "Genus" },
    #         { :name => 'species',
    #           :has_many => [
    #             { :name => :id,          :type => :integer                         },
    #             { :name => :name,        :type => :string, :title => "Species"     },
    #             { :name => :common_name, :type => :string, :title => "Common Name" }
    #           ]
    #         }
    #       ]
    #     }
    #   ]
    #
    # By IMW convention, the outer-most element of the Schema is still
    # an Array describing a collection of identical records even
    # though XML data must have a single root node, limiting the
    # collection to a single record.
    #
    # The first field of the Schema is named +genera+ and it uses the
    # special field property +has_many+ to denote that the field
    # points to a collection of sub-records.
    #
    # Each of these sub-records has its own sub-schema defined by the
    # Array that the +has_many+ property keys to.  In this case, the
    # two fields are +name+ and +species+.  +name+ is a simple String
    # value while +species+ itself points at another collection of
    # objects.
    #
    # This second-level nested record (a particular species) is itself
    # composed of the three (flat) fields +id+, +name+, and
    # +common_name+.  Note that the Schema doesn't know (or care) that
    # the +id+ field is contained in an XML attribute while the +name+
    # and +common_name+ fields are contained as text within daughter
    # nodes.
    #
    # A different way of structure the same information, this time
    # expressed in YAML:
    #
    #   ---                      
    #   Mandrillus:              
    #   - :species: sphinx       
    #     :name: Mandrill        
    #     :id: "113"             
    #   - :species: leucophaeus  
    #     :name: Drill           
    #     :id: "114"             
    #   Rungwecebus:             
    #   - :species: kipunji      
    #     :name: Kipunji         
    #     :id: "100"
    #
    # Would lead to a different Schema
    # 
    #   [
    #     { :name => :genus, :title => "Genus",
    #       :has_many => [
    #         { :name => :id,          :type => :integer                         },
    #         { :name => :name,        :type => :string, :title => "Common Name" },
    #         { :name => :species,     :type => :string, :title => "Species"     }
    #       ]
    #     }
    #   ]
    #
    # Where the unnecessary outer wrapper field +genera+ has been
    # dispensed with.
    #
    # In addition to "has many" relationships a record can have a
    # "has_one" relationship.  The above data might be expressed
    #
    #   ---                      
    #   Mandrillus:
    #     - species: sphinx       
    #       name: Mandrill        
    #       id: "113"
    #       discoverer:
    #         name: Dr. Monkeypants
    #         year: 1838
    #     - species: leucophaeus  
    #       name: Drill           
    #       id: "114"
    #       discoverer:
    #         name: Ms. Cecelia Apefingers
    #         year: 1921
    #
    # would result in the following Schema:
    #
    #   [
    #     { :name => :genus, :title => "Genus",
    #       :has_many => [
    #         { :name => :id,         :type => :integer                         },
    #         { :name => :name,       :type => :string, :title => "Common Name" },
    #         { :name => :species,    :type => :string                          },
    #         { :name => :discoverer,
    #           :has_one => [
    #             { :name => 'name', :type => :string  },
    #             { :name => 'year', :type => :integer }
    #           ]
    #         }
    #       ]
    #     }
    #   ]
    #
    # The +discoverer+ field is marked as +has_one+ which means the
    # +name+ and +year+ fields in the corresponding Array will be
    # interpreted as fields in a single attached sub-record.
    #
    # = Compact Schemas
    #
    # The internal hashes in a Schema specification are really Field
    # objects and the initializer will promote Strings and Symbols to
    # Field objects automatically.  This means that the above Schema
    # specification could be replaced by
    #
    #   [
    #     { :name => :genus
    #       :has_many => [
    #         :id,
    #         :name,
    #         :species,
    #         { :name => :discoverer,
    #           :has_one => [
    #             :name,
    #             :year
    #           ]
    #         }
    #       ]
    #     }
    #   ]
    #
    # though there is an accompanying loss of metadata about each
    # field.
    class Schema < Hash

      def self.meta_schema
        {
          :type      => "record",
          :name      => "resource",
          :namespace => "schema.imw",
          :doc       => "A meta-schema for IMW resources",
          :fields    => [
                         {
                           :name => "uri",
                           :doc  => "The URI of the resource",
                           :type => "string"
                         },
                         {
                           :name => "contents",
                           :doc  => "The resources contained inside this URI (optional)",
                           :type => [nil, "array"]
                         }
                        ]
        }
      end

      def initialize input=nil
        super()
      end

      def self.load resource
        new(IMW.open(resource).load)
      end

      def [] index
        [Integer, Range].include?(index.class) ? super(index) : detect { |field| field[:name].to_s == index.to_s }
      end
      
    end
  end
end
