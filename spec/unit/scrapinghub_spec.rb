require File.dirname(__FILE__) + "/../spec_helper"
require "rspec/autorun"

describe Scrapinghub do
  it "is equivalent to ScrapingHub" do
    expect(Scrapinghub).to be(ScrapingHub)
  end
end
