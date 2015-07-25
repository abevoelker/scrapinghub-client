require "rspec"
require "webmock/rspec"
require "vcr"
require "scrapinghub"

RSpec::Expectations.configuration.warn_about_potential_false_positives = false

VCR.configure do |config|
  config.cassette_library_dir = "spec/fixtures/vcr_cassettes"
  config.configure_rspec_metadata!
  config.hook_into :webmock
end

RSpec.configure do |c|
  c.extend VCR::RSpec::Macros
end
