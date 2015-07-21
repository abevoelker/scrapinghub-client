require File.dirname(__FILE__) + "/../spec_helper"
require "rspec/autorun"

describe ScrapingHub::Jobs do
  context "initialization" do
    context "api_key" do
      it "is required" do
        expect{ScrapingHub::Jobs.new}.to raise_error ParamContractError
      end

      it "must be a String" do
        expect{ScrapingHub::Jobs.new(api_key: 1)}.to raise_error ParamContractError
        expect(ScrapingHub::Jobs.new(api_key: "foo")).to be_a ScrapingHub::Jobs
      end
    end
  end

  context "#list" do
    it "is a pending example"
  end
end
