require './spec/rails_helper'
require 'yaml'

describe ApiViewVersions::Rack::Middleware do
  let(:app) do
    _config = config
    rack = Rack::Builder.new do
      use ApiViewVersions::Rack::Middleware, _config
      run lambda { |env| [ 200, {},[ "version is #{env['api_view_versions.context'].version}" ] ] }
    end
    Rack::MockRequest.new(rack)
  end
  let(:config) do
    config = ApiViewVersions::Configuration.new
    config.resources { |r| r.resource %r{.*}, [], [], (1..5) }
    config.vendor_string = 'myapp'
    config.mime_types = [ "text/html" ]
    config
  end

  test_cases = YAML.load(File.open('./spec/fixtures/test_cases.yml'))
  test_cases.each do |test_case|
    context 'for a test case' do
      let(:data) { test_case['request'] || {} }
      let(:method) { (data['method'] || 'get').to_sym }
      let(:headers) { data['headers'] || {} }
      let(:params) { data['params'] || {} }
      let(:test_response) { "version is #{test_case['response']}" }

      subject(:response) do
        begin
          response = app.request(method, '/renders', headers.merge(params: params))
          expect(response.body).to(eq(test_response), custom_message(headers, params, method, response.body, test_response))
        rescue => e
          raise custom_message(headers, params, method, response.body, test_response) + ", but it failed with an exception '#{e.message}'"
        end
      end

      context "full mode" do
        it "passes all tests" do
          expect { subject }.to_not raise_error
        end
      end

      context "performance mode" do
        let(:config) do
          config = ApiViewVersions::Configuration.new
          config.resources { |r| r.resource %r{.*}, [], [], (1..5) }
          config.vendor_string = 'myapp'
          config.mime_types = [ "text/html" ]
          config.performance_mode = true
          config
        end

        let(:test_response) { "version is #{test_case['response_short']}" }


        it "passes all tests" do
          expect { subject }.to_not raise_error
        end
      end
    end
  end

  def custom_message(headers, params, method, actual_response, expected_response)
    data = []
    data << "headers:#{headers}" if headers
    data << "params:#{params}" if params
    "Expected #{data.join(',')} with method #{method} to yield '#{expected_response}', but got '#{actual_response}'"
  end

  context 'when configured with unversioned template' do
    let(:config) do
      config = ApiViewVersions::Configuration.new
      config.resources { |r| r.resource %r{.*}, [], [], (1..5) }
      config.missing_version = :unversioned_template
      config
    end

    context 'and the request does not contain a version' do
      it 'does not include a version (rails will convert nil => unversioned template)' do
        response = app.request('get', '/renders')
        expect(response.body).to eq 'version is ' # nil
      end
    end
  end
end
