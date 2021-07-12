require 'spec_helper'
require 'rack'

describe ApiViewVersions::Rack::Middleware do
  let(:response_strategy) { nil }
  let(:config) do
    ApiViewVersions::Configuration.new.tap do |config|
      config.vendor_string = 'myapp'
      config.resources do |resource_config|
        resource_config.resource %r{.*}, [], [], (1..5)
      end
    end
  end
  let(:upstream_headers) { {} }
  let(:middleware) do
    ApiViewVersions::Rack::Middleware.new(
      double(call: [nil, upstream_headers, nil] ),
      config
    )
  end

  context '#call' do
    let(:env) do
      {
        'SCRIPT_NAME' => '',
        'PATH_INFO' => '',
        'HTTP_ACCEPT' => 'application/vnd.myapp+json;version=1'
      }
    end

    subject { middleware.call(env) }
    let(:response_headers) { subject[1] }

    it 'sets the version in the X-Content-Version' do
      expect(response_headers['X-Content-Version']).to match '1'
    end
  end
end
