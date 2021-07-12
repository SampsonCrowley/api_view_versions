require 'spec_helper'

describe ApiViewVersions::VersionContextService do

  let(:resource_user) do
    double(
      'user_resource',
      uri: %r{user},
      supported_versions: [5,6,7],
      deprecated_versions: [3,4],
      obsolete_versions: [1,2]
    )
  end
  let(:resource_all) do
    double(
      'default',
      uri: %r{.*},
      supported_versions: [6,7],
      deprecated_versions: [3,4,5],
      obsolete_versions: [1,2]
    )
  end
  let(:config) do
    double(
      'config',
      versioned_resources: [resource_user, resource_all],
      default_version: default_version,
      vendor_string: 'myapp'
    )
  end
  let(:default_version) { 6 }
  let(:service) { described_class.new(config) }

  describe '#create_context_from_request' do
    let(:request) { double(path: 'users/123', env: { 'HTTP_ACCEPT' => 'application/vnd.myapp+json;version=5' }) }
    subject(:context) { service.create_context_from_request(request) }

    it { expect(context.version).to eq 5 }
    it { expect(context.resource).to eq resource_user }
    it { expect(context.result).to eq :supported }

    context 'for a deprecated version' do
      let(:request) { double(path: 'posts/123', env: { 'HTTP_ACCEPT' => 'application/vnd.myapp+json;version=5' }) }

      it { expect(context.version).to eq 5 }
      it { expect(context.resource).to eq resource_all }
      it { expect(context.result).to eq :deprecated }
    end

    context 'for an obsolete version' do
      let(:request) { double(path: 'users/123', env: { 'HTTP_ACCEPT' => 'application/vnd.myapp+json;version=2' }) }

      it { expect(context.version).to eq 2 }
      it { expect(context.resource).to eq resource_user }
      it { expect(context.result).to eq :obsolete }
    end

    context 'for a missing version' do
      let(:request) { double(path: 'users/123', env: { }) }

      it { expect(context.version).to eq 6 }
      it { expect(context.resource).to eq resource_user }
      it { expect(context.result).to eq :supported }

      context 'when no default version is configured' do
        let(:default_version) { nil }

        it { expect(context.version).to eq nil }
        it { expect(context.resource).to eq resource_user }
        it { expect(context.result).to eq :no_version }

        context 'when the version is blank' do
          let(:request) { double(path: 'users/123', env: { 'HTTP_ACCEPT' => 'application/vnd.myapp+json' }) }

          it { expect(context.version).to eq nil }
          it { expect(context.resource).to eq resource_user }
          it { expect(context.result).to eq :no_version }
        end

        context 'when the version is invalid' do
          let(:request) { double(path: 'users/123', env: { 'HTTP_ACCEPT' => 'application/vnd.myapp+json;version=asdf' }) }

          it { expect(context.version).to eq nil }
          it { expect(context.resource).to eq resource_user }
          it { expect(context.result).to eq :version_invalid }
        end

        context 'when the weight is invalid' do
          let(:request) { double(path: 'users/123', env: { 'HTTP_ACCEPT' => 'application/vnd.myapp+json;q=asdf; version=2' }) }

          it { expect(context.version).to eq nil }
          it { expect(context.resource).to eq resource_user }
          it { expect(context.result).to eq :version_invalid }
        end

        context 'when the weight is invalid and there is no version' do
          let(:request) { double(path: 'users/123', env: { 'HTTP_ACCEPT' => 'application/vnd.myapp+json;q=asdf' }) }

          it { expect(context.version).to eq nil }
          it { expect(context.resource).to eq resource_user }
          it { expect(context.result).to eq :no_version }
        end

        context 'when the version is an empty key' do
          let(:request) { double(path: 'users/123', env: { 'HTTP_ACCEPT' => 'application/vnd.myapp+json;version=' }) }

          it { expect(context.version).to eq nil }
          it { expect(context.resource).to eq resource_user }
          it { expect(context.result).to eq :version_invalid }
        end
      end
    end

    context 'for an invalid version' do
      let(:request) { double(path: 'users/123', env: { 'HTTP_ACCEPT' => 'application/vnd.myapp+json;version=asdf' }) }

      it { expect(context.version).to eq nil }
      it { expect(context.resource).to eq resource_user }
      it { expect(context.result).to eq :version_invalid }
    end
  end

  describe '#create_context' do
    let(:uri) { 'users/21' }
    let(:version) { 5 }
    subject(:context) { service.create_context(uri, version) }

    it { expect(context.version).to eq 5 }
    it { expect(context.resource).to eq resource_user }
    it { expect(context.result).to eq :supported }

    context 'for a deprecated version' do
      let(:uri) { 'posts/21' }
      let(:version) { 5 }

      it { expect(context.version).to eq 5 }
      it { expect(context.resource).to eq resource_all }
      it { expect(context.result).to eq :deprecated }
    end

    context 'for an obsolete version' do
      let(:uri) { 'posts/21' }
      let(:version) { 2 }

      it { expect(context.version).to eq 2 }
      it { expect(context.resource).to eq resource_all }
      it { expect(context.result).to eq :obsolete }
    end
  end

  describe '#create_context_from_context' do
    let(:uri) { 'users/21' }
    let(:existing_version) { 1 }
    let(:existing_context) { service.create_context(uri, existing_version) }
    let(:version) { 5 }
    subject(:context) { service.create_context_from_context(existing_context, version) }

    it { expect(context.version).to eq 5 }
    it { expect(context.resource).to eq resource_user }
    it { expect(context.result).to eq :supported }

    context 'for a deprecated version' do
      let(:uri) { 'posts/21' }
      let(:version) { 5 }

      it { expect(context.version).to eq 5 }
      it { expect(context.resource).to eq resource_all }
      it { expect(context.result).to eq :deprecated }
    end

    context 'for an obsolete version' do
      let(:uri) { 'posts/21' }
      let(:version) { 2 }

      it { expect(context.version).to eq 2 }
      it { expect(context.resource).to eq resource_all }
      it { expect(context.result).to eq :obsolete }
    end
  end

  describe '#inject_version' do
    let(:context) { Struct.new(:version).new(5) }
    subject(:headers) { {} }

    it 'sets X-Content-Version header from a given context and header' do
      service.inject_version(context, headers)
      expect(headers['X-Content-Version']).to eq '5'
    end
  end
end
