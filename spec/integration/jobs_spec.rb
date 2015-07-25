require File.dirname(__FILE__) + "/../spec_helper"

describe "jobs integration" do
  let(:api_key) { "XXX" }
  let(:jobs)    { ScrapingHub::Jobs.new(api_key: api_key) }

  describe "list" do
    let(:action)        { :list }
    let(:valid_project) { 1 }
    let(:args)          { {project: valid_project} }

    context "project" do
      context "given a valid project ID" do
        before do
          stub_request(:get, "http://#{api_key}:@dash.scrapinghub.com/api/jobs/list.json?project=#{valid_project}").
            to_return(lambda{|_| File.new("spec/fixtures/jobs/list/project/valid.txt") })
        end

        it "returns a Right" do
          expect(jobs.send(action, args)).to be_a Kleisli::Either::Right
        end
      end

      context "given an invalid / non-owned project ID" do
        let(:invalid_project) { 2 }
        let(:args)            { {project: invalid_project} }

        before do
          stub_request(:get, "http://#{api_key}:@dash.scrapinghub.com/api/jobs/list.json?project=#{invalid_project}").
            to_return(lambda{|_| File.new("spec/fixtures/jobs/list/project/invalid.txt") })
        end

        it "returns a Left" do
          expect(jobs.send(action, args)).to be_a Kleisli::Either::Left
        end
      end
    end

    context "job" do
      context "given a single job" do
        let(:job)  { "1/1/6" }
        let(:args) { {project: valid_project, job: job} }

        before do
          stub_request(:get, "http://#{api_key}:@dash.scrapinghub.com/api/jobs/list.json?project=#{valid_project}&job=#{job}").
            to_return(lambda{|_| File.new("spec/fixtures/jobs/list/job/single.txt") })
        end

        it "returns the job" do
          js = jobs.send(action, args)
          expect(js).to be_a Kleisli::Either::Right
          expect(js.fmap{|j| j["total"]}.right).to eq(1)
        end
      end

      context "given a list of jobs" do
        let(:job)  { ["1/1/1", "1/1/2"] }
        let(:args) { {project: valid_project, job: job} }

        before do
          job_query = job.map{|j| "&job=#{j}" }.join
          stub_request(:get, "http://#{api_key}:@dash.scrapinghub.com/api/jobs/list.json?project=#{valid_project}#{job_query}").
            to_return(lambda{|_| File.new("spec/fixtures/jobs/list/job/list.txt") })
        end

        it "returns the jobs" do
          js = jobs.send(action, args)
          expect(js).to be_a Kleisli::Either::Right
          expect(js.fmap{|j| j["total"]}.right).to eq(2)
        end
      end

      context "given an invalid/non-existent job" do
        let(:job)  { "1/1/123" }
        let(:args) { {project: valid_project, job: job} }

        before do
          stub_request(:get, "http://#{api_key}:@dash.scrapinghub.com/api/jobs/list.json?project=#{valid_project}&job=#{job}").
            to_return(lambda{|_| File.new("spec/fixtures/jobs/list/job/invalid.txt") })
        end

        it "returns no jobs" do
          js = jobs.send(action, args)
          expect(js).to be_a Kleisli::Either::Right
          expect(js.fmap{|j| j["total"]}.right).to eq(0)
        end
      end
    end

    context "spider" do
      context "given a valid spider with ran jobs" do
        let(:spider) { "foo" }
        let(:args)   { {project: valid_project, spider: spider} }

        before do
          stub_request(:get, "http://#{api_key}:@dash.scrapinghub.com/api/jobs/list.json?project=#{valid_project}&spider=#{spider}").
            to_return(lambda{|_| File.new("spec/fixtures/jobs/list/spider/valid.txt") })
        end

        it "returns a Right with the list of spider jobs" do
          js = jobs.send(action, args)
          expect(js).to be_a Kleisli::Either::Right
          expect(js.fmap{|j| j["total"]}.right).to eq(5)
          expect(js.fmap{|j| j["jobs"]}.fmap(&:size).right).to eq(5)
        end
      end

      context "given an invalid or not-ran spider" do
        let(:spider) { "bar" }
        let(:args)   { {project: valid_project, spider: spider} }

        before do
          stub_request(:get, "http://#{api_key}:@dash.scrapinghub.com/api/jobs/list.json?project=#{valid_project}&spider=#{spider}").
            to_return(lambda{|_| File.new("spec/fixtures/jobs/list/spider/invalid.txt") })
        end

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
        let(:state) { "finished" }
        let(:args)  { {project: valid_project, state: state} }

        before do
          stub_request(:get, "http://#{api_key}:@dash.scrapinghub.com/api/jobs/list.json?project=#{valid_project}&state=#{state}").
            to_return(lambda{|_| File.new("spec/fixtures/jobs/list/state/finished.txt") })
        end

        it "returns a Right with the list of spider jobs" do
          js = jobs.send(action, args)
          expect(js).to be_a Kleisli::Either::Right
          expect(js.fmap{|j| j["total"]}.right).to eq(9)
          expect(js.fmap{|j| j["jobs"]}.fmap(&:size).right).to eq(9)
        end
      end

      context "given 'pending' without pending jobs" do
        let(:state) { "pending" }
        let(:args)  { {project: valid_project, state: state} }

        before do
          stub_request(:get, "http://#{api_key}:@dash.scrapinghub.com/api/jobs/list.json?project=#{valid_project}&state=#{state}").
            to_return(lambda{|_| File.new("spec/fixtures/jobs/list/state/pending.txt") })
        end

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
        let(:has_tag) { "foo" }
        let(:args)    { {project: valid_project, has_tag: has_tag} }

        before do
          stub_request(:get, "http://#{api_key}:@dash.scrapinghub.com/api/jobs/list.json?project=#{valid_project}&has_tag=#{has_tag}").
            to_return(lambda{|_| File.new("spec/fixtures/jobs/list/has_tag/single.txt") })
        end

        it "returns jobs with that tag" do
          js = jobs.send(action, args)
          expect(js).to be_a Kleisli::Either::Right
          expect(js.fmap{|j| j["total"]}.right).to eq(2)
          js.fmap{|j| j["jobs"].map{|j| j["tags"]} }.right.each do |tags|
            expect(tags).to include(has_tag)
          end
        end
      end

      context "given a list of tags" do
        let(:has_tag) { ["foo", "bar"] }
        let(:args) { {project: valid_project, has_tag: has_tag} }

        before do
          has_tag_query = has_tag.map{|t| "&has_tag=#{t}" }.join
          stub_request(:get, "http://#{api_key}:@dash.scrapinghub.com/api/jobs/list.json?project=#{valid_project}#{has_tag_query}").
            to_return(lambda{|_| File.new("spec/fixtures/jobs/list/has_tag/multiple.txt") })
        end

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
        let(:has_tag) { "baz" }
        let(:args) { {project: valid_project, has_tag: has_tag} }

        before do
          stub_request(:get, "http://#{api_key}:@dash.scrapinghub.com/api/jobs/list.json?project=#{valid_project}&has_tag=#{has_tag}").
            to_return(lambda{|_| File.new("spec/fixtures/jobs/list/has_tag/invalid.txt") })
        end

        it "returns no jobs" do
          js = jobs.send(action, args)
          expect(js).to be_a Kleisli::Either::Right
          expect(js.fmap{|j| j["total"]}.right).to eq(0)
        end
      end
    end

    context "lacks_tag" do
      context "given a single tag" do
        let(:lacks_tag) { "foo" }
        let(:args)      { {project: valid_project, lacks_tag: lacks_tag} }

        before do
          stub_request(:get, "http://#{api_key}:@dash.scrapinghub.com/api/jobs/list.json?project=#{valid_project}&lacks_tag=#{lacks_tag}").
            to_return(lambda{|_| File.new("spec/fixtures/jobs/list/lacks_tag/single.txt") })
        end

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
        let(:lacks_tag) { ["foo", "bar"] }
        let(:args)      { {project: valid_project, lacks_tag: lacks_tag} }

        before do
          lacks_tag_query = lacks_tag.map{|t| "&lacks_tag=#{t}" }.join
          stub_request(:get, "http://#{api_key}:@dash.scrapinghub.com/api/jobs/list.json?project=#{valid_project}#{lacks_tag_query}").
            to_return(lambda{|_| File.new("spec/fixtures/jobs/list/lacks_tag/multiple.txt") })
        end

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
        let(:lacks_tag) { "baz" }
        let(:args) { {project: valid_project, lacks_tag: lacks_tag} }

        before do
          stub_request(:get, "http://#{api_key}:@dash.scrapinghub.com/api/jobs/list.json?project=#{valid_project}&lacks_tag=#{lacks_tag}").
            to_return(lambda{|_| File.new("spec/fixtures/jobs/list/lacks_tag/invalid.txt") })
        end

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
        let(:count) { 3 }
        let(:args)  { {project: valid_project, count: count} }

        before do
          stub_request(:get, "http://#{api_key}:@dash.scrapinghub.com/api/jobs/list.json?project=#{valid_project}&count=#{count}").
            to_return(lambda{|_| File.new("spec/fixtures/jobs/list/count/3.txt") })
        end

        it "returns 3 responses" do
          js = jobs.send(action, args)
          expect(js).to be_a Kleisli::Either::Right
          expect(js.fmap{|j| j["total"]}.right).to eq(3)
        end
      end
    end

  end
end