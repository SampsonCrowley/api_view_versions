require 'spec_helper'

describe ApiViewVersions::VersionedRequest do
  context '#execute' do
    let(:default_version) { nil }
    let(:request) { double("REQUEST", env: request_env) }

    subject(:versioned_request) do
      req = ApiViewVersions::VersionedRequest.new request, default_version
      req.execute
      req
    end

    context 'with a supported version' do
      let(:request_env) { { 'HTTP_ACCEPT' => "application/vnd.myapp+json; version=2" } }

      it { expect(versioned_request.version).to eq 2 }
      it { expect(versioned_request.failed).to be_falsey }
    end

    context 'without a version' do
      let(:request_env) { { } }

      it { expect(versioned_request.version).to be_nil }
      it { expect(versioned_request.failed).to be_falsey }
    end

    context 'with a strategy failure' do
      let(:request_env) { { 'HTTP_ACCEPT' => "application/vnd.myapp+json; version=bad" } }

      it { expect(versioned_request.version).to be_nil }
      it { expect(versioned_request.failed).to be_truthy }
    end
  end
end
