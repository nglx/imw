module IMW

  class Uri

    attr_reader :scheme, :format

    @@schemes = {
      %r{^hdfs:} => 'Hdfs',
      %r{^s3:}   => 'S3',
    }

    @@formats = {
      %r{.csv$}   => 'Csv',
      %r{.tsv$}   => 'Tsv',
      %r{.json$}  => 'Json',
      %r{.ya?ml$} => 'Yaml',
    }

    def initialize uri
      @scheme = lookup_scheme(uri)
      @format = lookup_format(uri)
    end

    def lookup_scheme uri
      @@schemes.keys.each do |key|
        next unless uri =~ key
        return @@schemes[key]
      end
      'Local'
    end

    def lookup_format uri
      @@formats.keys.each do |key|
        next unless uri =~ key
        return @@formats[key]
      end
      raise InvalidFormatError.new("#{File.extname(uri)} is not currently supported")
    end

  end
end
