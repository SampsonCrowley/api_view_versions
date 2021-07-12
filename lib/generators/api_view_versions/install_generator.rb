require 'rails/generators'

module ApiViewVersions
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path('../../templates', __FILE__)

    desc 'Creates an ApiViewVersions initializer in your application.'
    def copy_initializer
      template 'api_view_versions.rb', 'config/initializers/api_view_versions.rb'
    end
  end
end
