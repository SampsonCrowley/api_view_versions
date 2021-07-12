ActionView::Resolver::PathParser.class_eval do
  def build_path_regex
    handlers = ActionView::Template::Handlers.extensions.map { |x| Regexp.escape(x) }.join("|")
    formats = ActionView::Template::Types.symbols.map { |x| Regexp.escape(x) }.join("|")
    locales = "[a-z]{2}(?:-[A-Z]{2})?"
    variants = "[^.]*"

    %r{
      \A
      (?:(?<prefix>.*)/)?
      (?<partial>_)?
      (?<action>.*?)
      (?:\.(?<locale>#{locales}))??
      (?:\.(?<format>#{formats}))??
      (?:\+(?<variant>#{variants}))??
      (?:\.v(?<version>[0-9]+))??
      (?:\.(?<handler>#{handlers}))?
      \z
    }x
  end

  def parse(path)
    @regex ||= build_path_regex
    match = @regex.match(path)
    {
      prefix: match[:prefix] || "",
      action: match[:action],
      partial: !!match[:partial],
      locale: match[:locale]&.to_sym,
      handler: match[:handler]&.to_sym,
      format: match[:format]&.to_sym,
      version: match[:version]&.to_sym,
      variant: match[:variant]
    }
  end
end
