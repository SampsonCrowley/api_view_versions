require 'spec_helper'

describe ApiViewVersions::ExtractionStrategy do
  describe "execute" do
    let(:config) do
      conf = ApiViewVersions::Configuration.new
      conf.vendor_string ="myapplication"

      conf
    end

    subject do
      inst = described_class.new(request)
      inst.instance_variable_set :@config, config
      inst.execute
    end


    context "a request with an HTTP_ACCEPT version retrieves the version" do
      let(:request) do
        instance_double(
          'Request',
          env: {'HTTP_ACCEPT' => 'application/vnd.myapplication+json; version=1'}
        )
      end

      it { is_expected.to eq [1] }
    end

    context "a request with a non-matching HTTP_ACCEPT key" do
      let(:request) { instance_double('Request', env: \
        {'HTTP_ACCEPT' => 'application/vnd.other+json; version=1'}) }

      it "returns an empty array" do
        expect(subject).to eq []
      end
    end

    context "a request without an HTTP_ACCEPT version" do
      let(:request) { instance_double('Request', env: \
        {'HTTP_ACCEPT' => 'application/vnd.myapplication+json; other=1'}) }

      it "returns an empty array" do
        expect(subject).to eq []
      end
    end

    context "a request with multiple equal weighted HTTP_ACCEPT versions" do
      let(:request) { instance_double('Request', env: \
        {'HTTP_ACCEPT' => 'application/vnd.myapplication+json; version=3, application/vnd.other+json; version=2, application/vnd.myapplication+json; version=1'}) }

      it "returns the the matching versions in order of occurance" do
        expect(subject).to eq [ 3, 1 ]
      end
    end

    context "a request with multiple weighted matches" do
      let(:request) { instance_double('Request', env: \
        {'HTTP_ACCEPT' => 'application/vnd.myapplication+json; version=2;q=0.1, application/vnd.other+json; version=1, application/vnd.myapplication+json; version=4, application/vnd.myapplication+json; q=0.545; version=6'}) }

      it "returns the the matching versions in order of weight" do
        expect(subject).to eq [ 4, 6, 2 ]
      end
    end
  end
end
