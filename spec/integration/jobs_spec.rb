require File.dirname(__FILE__) + "/../spec_helper"

shared_examples "connection_refused_returns_try" do
  before do
    stub_request(:any, "dash.scrapinghub.com").to_timeout
  end

  it "returns a Try::Failure when host is down" do
    expect(jobs.send(action, args)).to be_a Kleisli::Try::Failure
  end
end

shared_examples "bad_auth_returns_try" do |cassette|
  use_vcr_cassette cassette

  it "returns a Left when bad authentication is used" do
    js = jobs.send(action, args)
    expect(js).to be_a Kleisli::Either::Left
    expect(js.left.class).to eq HTTParty::Response
    expect(js.left.response).to be_a Net::HTTPForbidden
  end
end

describe "jobs integration" do
  let(:api_key) { "XXX" }
  let(:jobs)    { ScrapingHub::Jobs.new(api_key: api_key) }

  describe "list" do
    let(:action)        { :list }
    let(:valid_project) { 1 }
    let(:args)          { {project: valid_project} }

    it_behaves_like "connection_refused_returns_try"
    it_behaves_like "bad_auth_returns_try", "jobs/list/bad_auth"

    context "project" do
      context "given a valid project ID" do
        use_vcr_cassette "jobs/list/project/valid"

        it "returns a Right" do
          expect(jobs.send(action, args)).to be_a Kleisli::Either::Right
        end
      end

      context "given an invalid / non-owned project ID" do
        use_vcr_cassette "jobs/list/project/invalid"
        let(:invalid_project) { 2 }
        let(:args)            { {project: invalid_project} }

        it "returns a Left" do
          expect(jobs.send(action, args)).to be_a Kleisli::Either::Left
        end
      end
    end

    context "job" do
      context "given a single job" do
        use_vcr_cassette "jobs/list/job/single"
        let(:job)  { "1/1/6" }
        let(:args) { {project: valid_project, job: job} }

        it "returns the job" do
          js = jobs.send(action, args)
          expect(js).to be_a Kleisli::Either::Right
          expect(js.fmap{|j| j["total"]}.right).to eq(1)
        end
      end

      context "given a list of multiple jobs" do
        use_vcr_cassette "jobs/list/job/multiple"
        let(:job)  { ["1/1/1", "1/1/2"] }
        let(:args) { {project: valid_project, job: job} }

        it "returns the jobs" do
          js = jobs.send(action, args)
          expect(js).to be_a Kleisli::Either::Right
          expect(js.fmap{|j| j["total"]}.right).to eq(2)
        end
      end

      context "given an invalid/non-existent job" do
        use_vcr_cassette "jobs/list/job/invalid"
        let(:job)  { "1/1/123" }
        let(:args) { {project: valid_project, job: job} }

        it "returns no jobs" do
          js = jobs.send(action, args)
          expect(js).to be_a Kleisli::Either::Right
          expect(js.fmap{|j| j["total"]}.right).to eq(0)
        end
      end
    end

    context "spider" do
      context "given a valid spider with ran jobs" do
        use_vcr_cassette "jobs/list/spider/valid"
        let(:spider) { "atlantic_firearms_crawl" }
        let(:args)   { {project: valid_project, spider: spider} }

        it "returns a Right with the list of spider jobs" do
          js = jobs.send(action, args)
          expect(js).to be_a Kleisli::Either::Right
          expect(js.fmap{|j| j["total"]}.right).to eq(5)
          expect(js.fmap{|j| j["jobs"]}.fmap(&:size).right).to eq(5)
        end
      end

      context "given an invalid or not-ran spider" do
        use_vcr_cassette "jobs/list/spider/invalid"
        let(:spider) { "bar" }
        let(:args)   { {project: valid_project, spider: spider} }

        it "returns a Right with no results" do
          js = jobs.send(action, args)
          expect(js).to be_a Kleisli::Either::Right
          expect(js.fmap{|j| j["total"]}.right).to eq(0)
          expect(js.fmap{|j| j["jobs"]}.fmap(&:size).right).to eq(0)
        end
      end
    end

    context "state" do
      context "given 'finished' with completed jobs" do
        use_vcr_cassette "jobs/list/state/finished"
        let(:state) { "finished" }
        let(:args)  { {project: valid_project, state: state} }

        it "returns a Right with the list of spider jobs" do
          js = jobs.send(action, args)
          expect(js).to be_a Kleisli::Either::Right
          expect(js.fmap{|j| j["total"]}.right).to eq(9)
          expect(js.fmap{|j| j["jobs"]}.fmap(&:size).right).to eq(9)
        end
      end

      context "given 'pending' without pending jobs" do
        use_vcr_cassette "jobs/list/state/pending"
        let(:state) { "pending" }
        let(:args)  { {project: valid_project, state: state} }

        it "returns a Right without any jobs" do
          js = jobs.send(action, args)
          expect(js).to be_a Kleisli::Either::Right
          expect(js.fmap{|j| j["total"]}.right).to eq(0)
          expect(js.fmap{|j| j["jobs"]}.fmap(&:size).right).to eq(0)
        end
      end
    end

    context "has_tag" do
      context "given a single tag" do
        use_vcr_cassette "jobs/list/has_tag/single"
        let(:has_tag) { "foo" }
        let(:args)    { {project: valid_project, has_tag: has_tag} }

        it "returns jobs with that tag" do
          js = jobs.send(action, args)
          expect(js).to be_a Kleisli::Either::Right
          expect(js.fmap{|j| j["total"]}.right).to eq(2)
          js.fmap{|j| j["jobs"].map{|j| j["tags"]} }.right.each do |tags|
            expect(tags).to include(has_tag)
          end
        end
      end

      context "given a list of multiple tags" do
        use_vcr_cassette "jobs/list/has_tag/multiple"
        let(:has_tag) { ["foo", "bar"] }
        let(:args) { {project: valid_project, has_tag: has_tag} }

        it "returns all jobs with either tag" do
          js = jobs.send(action, args)
          expect(js).to be_a Kleisli::Either::Right
          expect(js.fmap{|j| j["total"]}.right).to eq(3)
          js.fmap{|j| j["jobs"].map{|j| j["tags"]} }.right.each do |tags|
            in_common = tags & has_tag
            expect(in_common).not_to be_empty
          end
        end
      end

      context "given an invalid/non-existent tag" do
        use_vcr_cassette "jobs/list/has_tag/invalid"
        let(:has_tag) { "baz" }
        let(:args) { {project: valid_project, has_tag: has_tag} }

        it "returns no jobs" do
          js = jobs.send(action, args)
          expect(js).to be_a Kleisli::Either::Right
          expect(js.fmap{|j| j["total"]}.right).to eq(0)
        end
      end
    end

    context "lacks_tag" do
      context "given a single tag" do
        use_vcr_cassette "jobs/list/lacks_tag/single"
        let(:lacks_tag) { "foo" }
        let(:args)      { {project: valid_project, lacks_tag: lacks_tag} }

        it "returns jobs with that tag" do
          js = jobs.send(action, args)
          expect(js).to be_a Kleisli::Either::Right
          expect(js.fmap{|j| j["total"]}.right).to eq(7)
          js.fmap{|j| j["jobs"].map{|j| j["tags"]} }.right.each do |tags|
            expect(tags).not_to include(lacks_tag)
          end
        end
      end

      context "given a list of tags" do
        use_vcr_cassette "jobs/list/lacks_tag/multiple"
        let(:lacks_tag) { ["foo", "bar"] }
        let(:args)      { {project: valid_project, lacks_tag: lacks_tag} }

        it "returns all jobs without either tag" do
          js = jobs.send(action, args)
          expect(js).to be_a Kleisli::Either::Right
          expect(js.fmap{|j| j["total"]}.right).to eq(6)
          js.fmap{|j| j["jobs"].map{|j| j["tags"]} }.right.each do |tags|
            in_common = tags & lacks_tag
            expect(in_common).to be_empty
          end
        end
      end

      context "given an invalid/non-existent tag" do
        use_vcr_cassette "jobs/list/lacks_tag/invalid"
        let(:lacks_tag) { "baz" }
        let(:args) { {project: valid_project, lacks_tag: lacks_tag} }

        it "returns no jobs" do
          js = jobs.send(action, args)
          expect(js).to be_a Kleisli::Either::Right
          expect(js.fmap{|j| j["total"]}.right).to eq(9)
          js.fmap{|j| j["jobs"].map{|j| j["tags"]} }.right.each do |tags|
            expect(tags).not_to include(lacks_tag)
          end
        end
      end
    end

    context "count" do
      context "given 3" do
        use_vcr_cassette "jobs/list/count/3"
        let(:count) { 3 }
        let(:args)  { {project: valid_project, count: count} }

        it "returns 3 responses" do
          js = jobs.send(action, args)
          expect(js).to be_a Kleisli::Either::Right
          expect(js.fmap{|j| j["total"]}.right).to eq(3)
        end
      end
    end

  end
end