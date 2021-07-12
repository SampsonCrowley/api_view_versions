module ApiViewVersions
  module ViewAdditionsSixZero
    def extract_handler_and_format_and_variant(path)
      super(path.sub(/\.v[0-9]+\.([^.]+)$/, '.\1'))
    end
  end
end

ActionView::PathResolver.prepend ApiViewVersions::ViewAdditionsSixZero
