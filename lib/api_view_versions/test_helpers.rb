module ApiViewVersions
  module TestHelpers
    # Test helper the mimics the middleware because we do not
    # have middleware during tests.
    def set_request_version(resource, version, config=ApiViewVersions.config)
      service = ApiViewVersions::VersionContextService.new(config)
      @request.env['api_view_versions.context'] = service.create_context resource, version
    end

    def set_version_context(status, resource=nil, version=nil)
      @request.env['api_view_versions.context'] = ApiViewVersions::VersionContext.new(version, resource, status)
    end
  end
end
