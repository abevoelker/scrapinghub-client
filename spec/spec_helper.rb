if ENV['CODECLIMATE_REPO_TOKEN']
  require "codeclimate-test-reporter"
  CodeClimate::TestReporter.start
end
require "rspec"
require "webmock/rspec"
require "vcr"
require "scrapinghub"

RSpec::Expectations.configuration.warn_about_potential_false_positives = false

VCR.configure do |config|
  config.cassette_library_dir = "spec/fixtures/vcr_cassettes"
  config.configure_rspec_metadata!
  config.hook_into :webmock
  # allow code coverage reports to be sent to Code Climate
  config.ignore_hosts "codeclimate.com"
end

RSpec.configure do |c|
  c.extend VCR::RSpec::Macros
end
