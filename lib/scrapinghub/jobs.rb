require "contracts"
require "kleisli"
require "httparty"

module ScrapingHub
  class Jobs
    include HTTParty
    include Contracts
    base_uri "dash.scrapinghub.com"

    Contract ({ :api_key => String }) => Any
    def initialize(api_key:)
      @api_key = api_key
    end

    Contract ({ :project => Num,
                :jobid => String,
                :spider => Or[String, nil],
                :state => Or["pending", "running", "finished", nil],
                :has_tag => Or[ArrayOf[String], nil],
                :lacks_tag => Or[ArrayOf[String], nil] }) => Or[Kleisli::Try, Kleisli::Either]
    def list(args)
      options = { query: args.reject{|_,v| v.nil? }, basic_auth: { username: @api_key } }
      Try { self.class.get("/api/jobs/list.json", options) } >-> response {
        if response.code == 200
          Right(response)
        else
          Left(response)
        end
      }
    end
  end
end
