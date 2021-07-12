require 'active_support/core_ext/module/attribute_accessors.rb'
require 'active_support/core_ext/array/wrap.rb'
require 'api_view_versions/versioned_resource'

module ApiViewVersions
  class Configuration
    attr_reader :versioned_resources, :default_version,
                :missing_version_use_unversioned_template,
                :mime_starts, :mime_ends
    attr_accessor :missing_version, :vendor_string, :rails_view_versioning, :mime_types, :performance_mode

    def initialize
      @versioned_resources           = []
      @vendor_string                 = nil
      @rails_view_versioning         = true
      @missing_version_use_unversioned_template = true
      @default_version = nil
      @performance_mode = false
      self.mime_types = [ "application/json" ]
    end

    def missing_version=(val)
      if val.is_a?(Integer)
        @missing_version = val
        @missing_version_use_unversioned_template = false
        @default_version = val
      else
        @missing_version = :unversioned_template
        @missing_version_use_unversioned_template = true
        @default_version = nil
      end
    end

    def mime_types=(arr)
      mime_types = %w[ application/json ] | Array.wrap(arr).flatten
      starts = []
      ends = []
      mime_types.each do |mime|
        splitted = mime.to_s.downcase.split("/")
        starts |= [ splitted.first ]
        ends |= [ splitted.last ]
      end

      @mime_starts = starts.map { |x| Regexp.escape(x) }.join("|")
      @mime_ends = ends.map { |x| Regexp.escape(x) }.join("|")
      mime_types
    end

    def resources
      builder = ResourceBuilder.new
      yield builder
      @versioned_resources = builder.resources
    end

    def validate!
      raise ApiViewVersions::ConfigError, 'vendor_string is required' unless vendor_string && vendor_string.length > 0
    end
  end

  class ResourceBuilder
    attr_reader :resources
    def initialize
      @resources = []
    end
    def resource(regex, obsolete, unsupported, supported)
      @resources << ApiViewVersions::VersionedResource.new(regex, obsolete, unsupported, supported)
    end
  end
end
