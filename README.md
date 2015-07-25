Scrapinghub
===========

[![Build Status](https://travis-ci.org/abevoelker/scrapinghub.svg?branch=master)][travis]
[![Dependency Status](https://gemnasium.com/abevoelker/scrapinghub.svg)][gemnasium]
[![Code Climate](https://codeclimate.com/github/abevoelker/scrapinghub/badges/gpa.svg)][codeclimate]
[![Test Coverage](https://codeclimate.com/github/abevoelker/scrapinghub/badges/coverage.svg)][codeclimate]

Ruby client for the [Scrapinghub API][api]. So far it only supports the [Jobs API][jobs-api] (pull requests accepted).

Install
--------

Add this to your Gemfile:

```
gem "scrapinghub", github: "abevoelker/scrapinghub"
```

Synopsis
--------

```ruby
require "scrapinghub"

# initialize a Jobs API client
j = ScrapingHub::Jobs.new(api_key: 'abc123')

# success returns a Kleisli::Either::Right
# failure returns a Kleisli::Try::Failure (e.g. if connection was refused) or
# a Kleisli::Either::Left (e.g. if bad credentials supplied or request malformed)
js = j.list(project: 123, job: ["123/1/1", "123/1/2"], state: "finished", has_tag: "foo", lacks_tag: "bar", count: 10)
```

[travis]: https://travis-ci.org/abevoelker/scrapinghub
[gemnasium]: https://gemnasium.com/abevoelker/scrapinghub
[codeclimate]: https://codeclimate.com/github/abevoelker/scrapinghub
[api]: http://doc.scrapinghub.com/api.html
[jobs-api]: http://doc.scrapinghub.com/jobs.html
