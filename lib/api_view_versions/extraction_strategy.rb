module ApiViewVersions
  class ExtractionStrategy
    def self.extract(request)
      versions = new(request).execute
      if versions.is_a?(Array) || versions.nil?
        versions || []
      else
        raise ExtractionStrategyError, "An unknown version extraction error occurred: Returned #{versions.class.inspect}."
      end
    end

    def initialize(request)
      @config = request.env['api_view_versions.config'] || ApiViewVersions.config
      @request = request
    end

    # Execute should return an array on numbers or nil. Any other results returned will raise
    # an exception.
    def execute
      if request.env.key?('HTTP_ACCEPT') \
      && (accept = request.env['HTTP_ACCEPT']) \
      && (accept =~ /;\s*version=/)
        sections = accept.to_s.split(",")
        performance_mode ? execute_short(sections) : execute_full(sections)
      else
        []
      end
    end

    def config
      @config
    end

    def request
      @request
    end

    def performance_mode
      config.performance_mode
    end

    def vendor_string
      config.vendor_string
    end

    def mime_starts
      config.mime_starts
    end

    def mime_ends
      config.mime_ends
    end

    def version_blank?(version)
      version.nil? || (version.is_a?(String) && version.length == 0)
    end

    def version_regex
      %r{
        (?:;\s*)
        (?:(?<prefix>version=))
        (?:(?<version>[^; ]+))??
        (?:\s*;|\s*\z)
      }x
    end

    def weight_regex
      %r{
        (?:;\s*)
        (?:(?<prefix>q=))
        (?:\s*(?<weight>[^;]+)\s*)??
        (?:;|\z)
      }x
    end

    def execute_short(accept)

      result = accept.detect {|type| is_match?(type) }

      [ get_version(result) ]
    end

    def execute_full(accept)
      has_weight = false

      matches = accept.reduce([]) do |arr, type|
        if is_match?(type)
          match = version_regex.match(type)

          version = get_version(type)

          weight, hw = get_weight(type)

          has_weight ||= hw

          arr << [ version, weight ]
        end
        arr
      end

      matches.sort! {|a,b| b[1] <=> a[1] } if has_weight

      matches.map(&:first)
    end

    private
      def is_match?(type)
        type =~ %r{(?:#{mime_starts})/vnd\.#{vendor_string}\+#{mime_ends}+;}
      end

      def get_version(type)
        match = version_regex.match(type)

        if match && match[:prefix]
          if version_blank?(unparsed = match[:version]) \
          || version_blank?(unparsed = unparsed.strip) \
          || unparsed !~ /\A[0-9]+\z/
            raise ExtractionStrategyError, "Invalid Version Format: #{version_blank?(unparsed) ? 'Empty Key' : unparsed}"
          else
            unparsed.to_i
          end
        end
      end

      def get_weight(type)
        has_weight = false
        match = weight_regex.match(type)
        weight = 1.0

        if match && match[:prefix]
          has_weight = true
          if version_blank?(unparsed = match[:weight]) \
          || version_blank?(unparsed = match[:weight].strip) \
          || unparsed !~ /\A[01](\.[0-9]+)?\z/
            raise ExtractionStrategyError, "Invalid Weight Format: #{version_blank?(unparsed) ? 'Empty Key' : unparsed}"
          else
            weight = [ unparsed.sub(/\A([0-1])(\.[0-9]{1,3})?/, '\1\2').to_f, 1.0 ].min
          end
        end

        [ weight, has_weight ]
      end
  end
end
