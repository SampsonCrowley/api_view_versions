require './spec/rails_helper'

describe ActionView::PathResolver do
  let(:resolver) { ActionView::PathResolver.new }

  context '#extract_handler_and_format_and_variant' do
    subject(:template_format) do
      args = if (ActionPack::VERSION::MAJOR < 5) || (ActionPack::VERSION::MAJOR == 5 && ActionPack::VERSION::MINOR == 0)
        [ nil ]
      else
        []
      end
      _, format, _ = resolver.__send__ :extract_handler_and_format_and_variant, "application.#{template_extension}", *args

      format.to_s
    end

    def rails_sixify(value)
      if ActionPack::VERSION::MAJOR > 5
        value.split("/").last
      else
        value
      end
    end

    context 'when only handler and format are present' do
      let(:template_extension) { 'html.erb' }

      it { expect(template_format).to eq rails_sixify("text/html") }
    end

    context 'when handler, format and version are present' do
      let(:template_extension) { 'json.v1.jbuilder' }

      it { expect(template_format).to eq rails_sixify("application/json") }
    end

    context 'when handler, format and locale are present' do
      let(:template_extension) { 'en.json.jbuilder' }

      it { expect(template_format).to eq rails_sixify("application/json") }
    end

    context 'when handler, format, locale and version are present' do
      let(:template_extension) { 'en.json.v1.jbuilder' }

      it { expect(template_format).to eq rails_sixify("application/json") }
    end

    context 'when handler, format, variant and version are present' do
      let(:template_extension) { 'application.json+tablet.v1.jbuilder' }

      it { expect(template_format).to eq rails_sixify("application/json") }
    end
  end
end
