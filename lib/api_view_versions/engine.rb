module ApiViewVersions
  class Engine < Rails::Engine
    initializer 'api_view_versions.add_middleware' do |app|
      app.middleware.use ApiViewVersions::Rack::Middleware
    end
  end
end
