module IMW
  module Metadata
    
    # A class to describe a schema for some collection of data.
    #
    # == Tabular Data
    #
    # Tabular data formats (CSV, TSV, &c.) have a simple schema
    # consisting of repeating records with the same fields in the same
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
    # A simple schema for this dataset might be expressed as a Ruby data
    # structure in the following way
    #
    #   [
    #     { :name => :id,      :type => :integer                         },
    #     { :name => :name,    :type => :string, :title => "Common Name" },
    #     { :name => :genus,   :type => :string, :title => "Genus"       },
    #     { :name => :species, :type => :string, :title => "Species"     }
    #   ]
    #
    # Each Hash here represents an IMW::Metadata::Field.
    #
    # == Hierarchical Data
    #
    # Hierarchical data formats (JSON, YAML, XML, &c.) can have
    # arbitrarily complex schemas with fields within fields and so on.
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
    # The simple schema used for this dataset might look like
    #
    #   [
    #     { :name     => :genera, :type => :array
    #       :contains => [
    #         { :name => :name,    :type => :string, title => "Genus" },
    #         { :name => :species, :type => :array
    #           :contains => [
    #             { :name => :id,          :type => :integer                         },
    #             { :name => :name,        :type => :string, :title => "Species"     },
    #             { :name => :common_name, :type => :string, :title => "Common Name" }
    #           ]
    #         }
    #       ]
    #     }
    #   ]
    #
    # A different nesting scheme for the data, seen here in YAML
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
    # Would lead to a different schema
    # 
    #   [
    #     { :name => :genus, :type => :array, title => "Genus",
    #       :contains => [
    #         { :name => :id,          :type => :integer                         },
    #         { :name => :name,        :type => :string, :title => "Species"     },
    #         { :name => :common_name, :type => :string, :title => "Common Name" }
    #       ]
    #     }
    #   ]
    #
    # In all cases, a Hash with a key <tt>:name</tt> denotes an
    # IMW::Metadata::Field.  The <tt>:contains</tt> key asserts that the field
    # contains identical instances with schema given by its value.
    #
    # In addition to containing a collection of similar objects
    # (associations), a field can also have sub-fields within it.
    # Making the following change to the above dataset
    #
    #   ---                      
    #   Mandrillus:
    #     :created:
    #       :year: 1876
    #       :biologist: Dr. Monkeypants
    #     :species:
    #     - :species: sphinx       
    #       :name: Mandrill        
    #       :id: "113"             
    #     - :species: leucophaeus  
    #       :name: Drill           
    #       :id: "114"             
    #   Rungwecebus:
    #     :created:
    #       :year: 1902
    #       :biologist: Ms. Cecilia Apefingers
    #     :species:
    #     - :species: kipunji      
    #       :name: Kipunji         
    #       :id: "100"
    #
    # would result in the following change to the schema
    #
    #   [
    #     { :name => :genus, :type => :hash, title => "Genus",
    #       :fields => [
    #         { :name => :created, :type => :hash,
    #           :fields => [
    #             { :name => :year, :type => :integer, :title => "Year" },
    #             { :name => :biologist, :type => :string, :description => "Biologist responsible for definition" }
    #           ]
    #         },
    #         { :name => :species, :type => :array,
    #           :contains => [
    #             { :name => :id,          :type => :integer                         },
    #             { :name => :name,        :type => :string, :title => "Species"     },
    #             { :name => :common_name, :type => :string, :title => "Common Name" }
    #           ]
    #         }
    #       ]
    #     }
    #   ]
    #
    # The outer-most element of a Schema should always be an Array.
    class Schema < Array

      def initialize input=nil
        super()
        concat(input.map { |field| IMW::Metadata::Field.new(field) }) if input
      end

      def self.load resource
        new(IMW.open(resource).load)
      end
    end
  end
end
