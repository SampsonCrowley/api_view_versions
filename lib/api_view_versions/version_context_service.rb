require 'api_view_versions/version_context'
require 'api_view_versions/versioned_request'
require 'api_view_versions/version_checker'

module ApiViewVersions
  class VersionContextService

    def initialize(config)
      @versioned_resources = config.versioned_resources
      @default_version = config.default_version
    end

    def create_context_from_request(raw_request)
      return unless resource = find_resource(raw_request.path)

      request = ApiViewVersions::VersionedRequest.new(
                  raw_request,
                  @default_version
                )
      request.execute

      result = if request.failed
        :version_invalid
      else
        check_version(resource, request.version)
      end

      ApiViewVersions::VersionContext.new(request.version, resource, result)
    end

    def create_context(uri, version)
      return unless resource = find_resource(uri)

      result = check_version(resource, version)

      ApiViewVersions::VersionContext.new(version, resource, result)
    end

    def create_context_from_context(context, version)
      result = check_version(context.resource, version)

      ApiViewVersions::VersionContext.new(version, context.resource, result)
    end

    def inject_version(context, headers)
      headers['X-Content-Version'] = context.version.to_s
    rescue
      nil
    end

    private
      def check_version(resource, version)
        ApiViewVersions::VersionChecker.new(version, resource).execute
      end

      def find_resource(uri)
        @versioned_resources.find { |resource| resource.uri.match uri }
      end
  end
end
