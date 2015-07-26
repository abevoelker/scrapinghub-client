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
    # Initialize a new Jobs API client
    #
    # @param api_key [String] Scrapinghub API key
    #
    # @return Object
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
    # Retrieve information about jobs.
    #
    # @param project [Fixnum] the project's numeric ID
    # @param job [String, Array<String>] (optional) ID(s) of specific jobs to
    #   retrieve
    # @param spider [String] (optional) a spider name (only jobs belonging to
    #   this spider will be returned)
    # @param state [String] (optional) return only jobs with this state. Valid
    #   values: "pending", "running", "finished"
    # @param has_tag [String, Array<String>] (optional) return only jobs
    #   containing the given tag(s)
    # @param lacks_tag [String, Array<String>] (optional) return only jobs not
    #   containing the given tag(s)
    # @param count [Fixnum] (optional) maximum number of jobs to return
    #
    # @return [Kleisli::Try, Kleisli::Either] a Kleisli::Try if a low-level
    #   exception is raised (e.g. the host is down), a Kleisli::Either::Left
    #   if validation fails (e.g. bad authentication), or a
    #   Kleisli::Either::Right if everything was successful.
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

    Contract KeywordArgs[:project => Nat,
                         :spider => String,
                         :add_tag => Optional[Or[String, ArrayOf[String]]],
                         :priority => Optional[Or[0, 1, 2, 3, 4]],
                         :extra => Optional[HashOf[Symbol => String]] ] => Or[Kleisli::Try, Kleisli::Either]
    # Schedule a job.
    #
    # @param project [Fixnum] the project's numeric ID
    # @param spider [String] the spider name
    # @param add_tag [String, Array<String>] (optional) add tag(s) to the job
    # @param priority [Fixnum] (optional) set the job priority: possible values
    #   range from 0 (lowest priority) to 4 (highest priority), default is 2
    # @param extra [Hash] (optional) extra parameters passed as spider
    #   arguments
    #
    # @return [Kleisli::Try, Kleisli::Either] a Kleisli::Try if a low-level
    #   exception is raised (e.g. the host is down), a Kleisli::Either::Left
    #   if validation fails (e.g. bad authentication), or a
    #   Kleisli::Either::Right if everything was successful.
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
    # Update information about jobs.
    #
    # @param project [Fixnum] the project's numeric ID
    # @param job [String, Array<String>] (optional) ID(s) of specific jobs to
    #   update
    # @param spider [String] (optional) query on spider name to update
    # @param state [String] (optional) query on jobs with this state to update.
    #   Valid values: "pending", "running", "finished"
    # @param has_tag [String, Array<String>] (optional) query on jobs
    #   containing the given tag(s) to update
    # @param lacks_tag [String, Array<String>] (optional) query on jobs not
    #   containing the given tag(s) to update
    # @param add_tag [String, Array<String>] (optional) tag(s) to add to the
    #   queried jobs
    # @param remove_tag [String, Array<String>] (optional) tag(s) to remove
    #   from the queried jobs
    #
    # @return [Kleisli::Try, Kleisli::Either] a Kleisli::Try if a low-level
    #   exception is raised (e.g. the host is down), a Kleisli::Either::Left
    #   if validation fails (e.g. bad authentication), or a
    #   Kleisli::Either::Right if everything was successful.
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
    # Delete one or more jobs.
    #
    # @param project [Fixnum] the project's numeric ID
    # @param job [String, Array<String>] the ID of a specific job to delete
    #
    # @return [Kleisli::Try, Kleisli::Either] a Kleisli::Try if a low-level
    #   exception is raised (e.g. the host is down), a Kleisli::Either::Left
    #   if validation fails (e.g. bad authentication), or a
    #   Kleisli::Either::Right if everything was successful.
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
    # Stop one or more running jobs.
    #
    # @param project [Fixnum] the project's numeric ID
    # @param job [String] the ID of a job to stop
    #
    # @return [Kleisli::Try, Kleisli::Either] a Kleisli::Try if a low-level
    #   exception is raised (e.g. the host is down), a Kleisli::Either::Left
    #   if validation fails (e.g. bad authentication), or a
    #   Kleisli::Either::Right if everything was successful.
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
