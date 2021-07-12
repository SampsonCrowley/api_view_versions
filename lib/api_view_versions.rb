require 'api_view_versions/extraction_strategy'

require 'api_view_versions/exceptions'
require 'api_view_versions/configuration'
require 'api_view_versions/rack/middleware'

if defined?(Rails)
  # require 'api_view_versions/controller_additions'
  # require 'api_view_versions/view_additions'
  # require 'api_view_versions/engine'
  require 'api_view_versions/railtie'
end

module ApiViewVersions

  mattr_accessor :config

  self.config = ApiViewVersions::Configuration.new

  # Yield self on setup for nice config blocks
  def self.setup
    yield self.config

    self.config.validate!
  end
end
