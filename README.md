Scrapinghub client
==================

[![Build Status](https://travis-ci.org/abevoelker/scrapinghub-client.svg?branch=master)][travis]
[![Dependency Status](https://gemnasium.com/abevoelker/scrapinghub-client.svg)][gemnasium]
[![Code Climate](https://codeclimate.com/github/abevoelker/scrapinghub-client/badges/gpa.svg)][codeclimate]
[![Test Coverage](https://codeclimate.com/github/abevoelker/scrapinghub-client/badges/coverage.svg)][codeclimate]

Ruby client for the [Scrapinghub API][api]. So far it only supports the [Jobs API][jobs-api] (pull requests welcome).

This library tries to take an FP-ish approach. It uses the [contracts gem][contracts] for validating function input and output types (see the [docs][] for the full list of functions and their types) and the [kleisli gem][kleisli] for returning composition-friendly output types. Outputs will be a `Left` if the Scrapinghub API returns failure or if an exception was raised (e.g. a network timeout), or a `Right` if the operation was successful.

The Kleisli gem [introductory blog post][kleisli-blog] gives some great examples on how to work with the output types.

Install
--------

Add to Gemfile:

```
gem "scrapinghub-client"
```

**Note**: although the gem is named `scrapinghub-client`, the gem's namespace is `Scrapinghub`.

Example
--------

```ruby
require "scrapinghub-client"

j = Scrapinghub::Jobs.new(api_key: 'abc123')
j.schedule(project: 123, spider: "foo", add_tag: "bar", extra: { DOWNLOAD_DELAY: "0.5" })
  .fmap{|r| puts "Job scheduled! Jobid: #{r['jobid']}"}
  .or{|f| puts "Failed to schedule job! Reason: #{f.value}"}
```

[travis]: https://travis-ci.org/abevoelker/scrapinghub-client
[gemnasium]: https://gemnasium.com/abevoelker/scrapinghub-client
[codeclimate]: https://codeclimate.com/github/abevoelker/scrapinghub-client
[api]: http://doc.scrapinghub.com/api.html
[jobs-api]: http://doc.scrapinghub.com/jobs.html
[docs]: http://www.rubydoc.info/github/abevoelker/scrapinghub-client/master/Scrapinghub/Jobs
[contracts]: https://github.com/egonSchiele/contracts.ruby/blob/master/TUTORIAL.md
[kleisli]: https://github.com/txus/kleisli
[kleisli-blog]: http://thoughts.codegram.com/cleaner-safer-ruby-api-clients-with-kleisli/
