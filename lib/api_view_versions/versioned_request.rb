module ApiViewVersions
  class VersionedRequest
    attr_reader :failed, :version, :additional_versions, :is_default

    def initialize(request, default_version=nil)
      @request, @default_version, @failed = request, default_version, false
    end

    def execute
      begin
        @is_default = false
        @failed = false

        @additional_versions = extract_versions

        if @additional_versions.length == 0
          @is_default = true
          @version = @default_version
        else
          @version = @additional_versions.shift
        end
      rescue
        @failed = true
      end
    end

    private
      def extract_versions
        ExtractionStrategy.extract(@request) || []
      end
  end
end
