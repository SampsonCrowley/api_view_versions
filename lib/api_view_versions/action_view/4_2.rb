module ApiViewVersions
  module ViewAdditionsFourTwo
    # def initialize(pattern = nil)
    #   @pattern = pattern || ":prefix/:action{.:locale,}{.:formats,}{+:variants,}{.:versions,}{.:handlers,}"
    #   super()
    # end

    def extract_handler_and_format_and_variant(path, default_formats)
      super(path.sub(/\.v[0-9]+\.([^.]+)$/, '.\1'), default_formats)
    end
  end
end

ActionView::PathResolver.prepend ApiViewVersions::ViewAdditionsFourTwo
