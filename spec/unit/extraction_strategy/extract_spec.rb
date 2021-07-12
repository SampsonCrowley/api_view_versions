require 'spec_helper'

# TODO: make better!!!
describe ApiViewVersions::ExtractionStrategy do
  describe "extract" do
    it "accepts an array result" do
      class TestBasicStrategy < ApiViewVersions::ExtractionStrategy
        def initialize(*); end
        def execute; [123]; end
      end

      expect(TestBasicStrategy.extract("request")).to eq [123]
    end

    it "cooerces an empty array result" do
      class TestNilStrategy < ApiViewVersions::ExtractionStrategy
        def initialize(*); end
        def execute; nil; end
      end

      expect(TestNilStrategy.extract("request")).to eq []
    end

    it "throws an exception the result is not an array or nil" do
      class TestInvalidStrategy < ApiViewVersions::ExtractionStrategy
        def initialize(*); end
        def execute; Object.new; end
      end

      expect { TestInvalidStrategy.extract("request") }.to raise_error(ApiViewVersions::ExtractionStrategyError)
    end
  end
end
