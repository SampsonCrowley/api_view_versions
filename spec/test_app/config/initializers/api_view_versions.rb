ApiViewVersions.setup do |config|
  # Versioned Resources
  # Define what server resources are supported, deprecated or obsolete
  # Resources listed are priority based upon creation. To version all
  # resources you can define a catch all at the bottom of the block.
  config.resources do |r|
    # r.resource uri_regex, obsolete, deprecated, supported
    r.resource %r{renders/*}, [2], [4], (1..5)
  end

  # Extraction Strategy Vendor String (Required)
  # Ex: config.vendor_string = 'myapp' # => # Accept application/vnd.myapp+xml; version=7
  config.vendor_string = "myapp"

  # Missing Version
  # What to use when no version in present in the request.
  #
  # Defaults to `:unversioned_template`
  #
  # Integer value:
  #   the version number to use
  #
  # `:unversioned_template` value:
  # If you are using `rails_view_versioning` this will render the "base template" aka
  # the template without a version number.
  config.missing_version = 3

  # Enable Rails versioned filename mapping
  # config.rails_view_versioning = true

  config.mime_types = %w[ text/html text/xml application/json ]
end
