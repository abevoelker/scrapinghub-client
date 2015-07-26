require "contracts"
require "kleisli"
require "httparty"

module ScrapingHub
  class Jobs
    include Contracts
    include HTTParty
    disable_rails_query_string_format
    base_uri "dash.scrapinghub.com"

    Contract ({ :api_key => String }) => Any
    def initialize(api_key:)
      @api_key = api_key
    end

    Contract KeywordArgs[:project => Nat,
                         :job => Optional[Or[String, ArrayOf[String]]],
                         :spider => Optional[String],
                         :state => Optional[Or["pending", "running", "finished"]],
                         :has_tag => Optional[Or[String, ArrayOf[String]]],
                         :lacks_tag => Optional[Or[String, ArrayOf[String]]],
                         :count => Optional[Nat] ] => Or[Kleisli::Try, Kleisli::Either]
    def list(args)
      options = { query: args, basic_auth: { username: @api_key } }
      Try { self.class.get("/api/jobs/list.json", options) } >-> response {
        if response.code == 200
          Right(response)
        else
          Left(response)
        end
      }
    end

    # TODO: jobs/list.jl

    Contract KeywordArgs[:project => Nat,
                         :spider => String,
                         :add_tag => Optional[Or[String, ArrayOf[String]]],
                         :priority => Optional[Or[0, 1, 2, 3, 4]],
                         :extra => Optional[HashOf[Symbol => String]] ] => Or[Kleisli::Try, Kleisli::Either]
    def schedule(args)
      extra = args.delete(:extra) || {}
      options = { body: args.merge(extra), basic_auth: { username: @api_key } }
      Try { self.class.post("/api/schedule.json", options) } >-> response {
        if response.code == 200
          Right(response)
        else
          Left(response)
        end
      }
    end

    Contract KeywordArgs[:project => Nat,
                         :job => Optional[Or[String, ArrayOf[String]]],
                         :spider => Optional[String],
                         :state => Optional[Or["pending", "running", "finished"]],
                         :has_tag => Optional[Or[String, ArrayOf[String]]],
                         :lacks_tag => Optional[Or[String, ArrayOf[String]]],
                         :add_tag => Optional[Or[String, ArrayOf[String]]],
                         :remove_tag => Optional[Or[String, ArrayOf[String]]] ] => Or[Kleisli::Try, Kleisli::Either]
    def update(args)
      options = { body: args, basic_auth: { username: @api_key } }
      Try { self.class.post("/api/jobs/update.json", options) } >-> response {
        if response.code == 200
          Right(response)
        else
          Left(response)
        end
      }
    end

    Contract KeywordArgs[:project => Nat,
                         :job => Or[String, ArrayOf[String]] ] => Or[Kleisli::Try, Kleisli::Either]
    def delete(args)
      options = { body: args, basic_auth: { username: @api_key } }
      Try { self.class.post("/api/jobs/delete.json", options) } >-> response {
        if response.code == 200
          Right(response)
        else
          Left(response)
        end
      }
    end

    Contract KeywordArgs[:project => Nat,
                        :job => String ] => Or[Kleisli::Try, Kleisli::Either]
    def stop(args)
      options = { body: args, basic_auth: { username: @api_key } }
      Try { self.class.post("/api/jobs/stop.json", options) } >-> response {
        if response.code == 200
          Right(response)
        else
          Left(response)
        end
      }
    end

  end
end
