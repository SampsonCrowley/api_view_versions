require 'api_view_versions/version_context_service'

module ApiViewVersions
  module Rack
    class Middleware

      def initialize(app, config=ApiViewVersions.config)
        @app = app
        @version_service = ApiViewVersions::VersionContextService.new(config)
        @config = config
      end

      def call(env)
        request = ::Rack::Request.new env
        env['api_view_versions.config'] = @config
        if context = @version_service.create_context_from_request(request)
          env['api_view_versions.context'] = context

          status, headers, response = @app.call(env)

          @version_service.inject_version(context, headers)

          [status, headers, response]
        else
          @app.call(env)
        end
      end
    end
  end
end
