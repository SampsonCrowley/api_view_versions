require 'action_controller/metal/exceptions'

module ApiViewVersions
  class ConfigError < ::Exception; end

  class ExtractionStrategyError < ::StandardError; end

  class UnsupportedVersionError < ::ActionController::RoutingError; end

  class ObsoleteVersionError < ::ActionController::RoutingError; end

  class MissingVersionError < ::ActionController::RoutingError; end
end
