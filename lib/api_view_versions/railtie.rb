require 'rails/railtie'

class Railtie < ::Rails::Railtie
  initializer 'api_view_versions.add_middleware' do |app|
    app.middleware.use ApiViewVersions::Rack::Middleware
  end

  initializer 'api_view_versions.action_controller' do
    ActiveSupport.on_load :action_controller do
      require 'api_view_versions/controller_additions'
      include ApiViewVersions::ControllerAdditions
    end
  end

  initializer 'api_view_versions.action_view' do
    ActiveSupport.on_load :action_view do
      require 'api_view_versions/view_additions'
    end
  end
end
