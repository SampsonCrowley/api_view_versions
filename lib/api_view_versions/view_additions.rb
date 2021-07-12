require 'action_view'
require 'action_view/template/resolver'

Kernel::silence_warnings {
  ActionView::PathResolver::DEFAULT_PATTERN = ":prefix/:action{.:locale,}{.:formats,}{+:variants,}{.:versions,}{.:handlers,}"
}

# register an addition detail for the lookup context to understand,
# this will allow us to have the versions available upon lookup in
# the resolver.
ActionView::LookupContext.register_detail(:versions){ [] }

if ActionPack::VERSION::MAJOR > 5
  if ActionPack::VERSION::MINOR > 0
    require "api_view_versions/action_view/6_1"
  else
    require "api_view_versions/action_view/6_0"
  end
elsif ActionPack::VERSION::MAJOR == 5
  if ActionPack::VERSION::MINOR > 0
    require "api_view_versions/action_view/5_1"
  else
    require "api_view_versions/action_view/5_0"
  end
elsif ActionPack::VERSION::MAJOR == 4 && ActionPack::VERSION::MINOR > 1
  require "api_view_versions/action_view/4_2"
else
  raise "incompatible version"
end

ActionView::PathResolver::EXTENSIONS.replace({
  locale: ".",
  formats: ".",
  versions: ".",
  variants: "+",
  handlers: "."
})

ActionView::Template.class_eval do
  # the identifier method name filters out numbers,
  # but we want to preserve them for v1 etc.
  def identifier_method_name #:nodoc:
    inspect.gsub(/[^a-z0-9_]/, '_')
  end
end
