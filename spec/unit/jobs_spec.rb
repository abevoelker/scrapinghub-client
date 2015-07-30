require File.dirname(__FILE__) + "/../spec_helper"
require "rspec/autorun"

shared_examples "disallows_unknown_keys" do
  it "disallows unknown keys" do
    expect{jobs.send(action, args.merge(foo: "blah"))}.to raise_error ParamContractError
  end
end

describe Scrapinghub::Jobs do
  let(:jobs) { Scrapinghub::Jobs.new(api_key: 'XXX') }

  context "initialization" do
    context "api_key" do
      it "is required" do
        expect{Scrapinghub::Jobs.new}.to raise_error ParamContractError
        expect{Scrapinghub::Jobs.new({})}.to raise_error ParamContractError
      end

      it "must be a String" do
        expect{Scrapinghub::Jobs.new(api_key: nil)}.to raise_error ParamContractError
        expect{Scrapinghub::Jobs.new(api_key: 1)}.to raise_error ParamContractError
        expect(Scrapinghub::Jobs.new(api_key: "foo")).to be_a Scrapinghub::Jobs
      end
    end
  end

  context "#list" do
    let(:action) { :list }
    let(:args)   { {project: 1} }

    it_behaves_like "disallows_unknown_keys"

    context "valid arguments" do
      it "passes argument validation" do
        expect{jobs.send(action, args)}.not_to raise_error ParamContractError
      end
    end

    context "project" do
      it "is required" do
        expect{jobs.send(action, args.reject{|k,_| k == :project})}.to raise_error ParamContractError
      end

      it "must be a natural number" do
        expect{jobs.send(action, args.merge(project: nil))}.to raise_error ParamContractError
        expect{jobs.send(action, args.merge(project: "foo"))}.to raise_error ParamContractError
        expect{jobs.send(action, args.merge(project: 1.234))}.to raise_error ParamContractError
        expect{jobs.send(action, args.merge(project: -1))}.to raise_error ParamContractError
        expect{jobs.send(action, args.merge(project: 1))}.not_to raise_error ParamContractError
      end
    end

    context "job" do
      it "must be a String or Array[String]" do
        expect{jobs.send(action, args.merge(job: nil))}.to raise_error ParamContractError
        expect{jobs.send(action, args.merge(job: 1.234))}.to raise_error ParamContractError
        expect{jobs.send(action, args.merge(job: -1))}.to raise_error ParamContractError
        expect{jobs.send(action, args.merge(job: 1))}.to raise_error ParamContractError
        expect{jobs.send(action, args.merge(job: "foo"))}.not_to raise_error ParamContractError
        expect{jobs.send(action, args.merge(job: ["foo", "bar"]))}.not_to raise_error ParamContractError
      end
    end

    context "spider" do
      it "must be a String" do
        expect{jobs.send(action, args.merge(spider: nil))}.to raise_error ParamContractError
        expect{jobs.send(action, args.merge(spider: 1.234))}.to raise_error ParamContractError
        expect{jobs.send(action, args.merge(spider: -1))}.to raise_error ParamContractError
        expect{jobs.send(action, args.merge(spider: 1))}.to raise_error ParamContractError
        expect{jobs.send(action, args.merge(spider: "foo"))}.not_to raise_error ParamContractError
      end
    end

    context "state" do
      it "must be 'pending', 'running', or 'finished'" do
        expect{jobs.send(action, args.merge(state: nil))}.to raise_error ParamContractError
        expect{jobs.send(action, args.merge(state: []))}.to raise_error ParamContractError
        expect{jobs.send(action, args.merge(state: "foo"))}.to raise_error ParamContractError
        expect{jobs.send(action, args.merge(state: "pending"))}.not_to raise_error ParamContractError
        expect{jobs.send(action, args.merge(state: "running"))}.not_to raise_error ParamContractError
        expect{jobs.send(action, args.merge(state: "finished"))}.not_to raise_error ParamContractError
      end
    end

    context "has_tag" do
      it "must be a String or Array[String]" do
        expect{jobs.send(action, args.merge(has_tag: nil))}.to raise_error ParamContractError
        expect{jobs.send(action, args.merge(has_tag: 1.234))}.to raise_error ParamContractError
        expect{jobs.send(action, args.merge(has_tag: -1))}.to raise_error ParamContractError
        expect{jobs.send(action, args.merge(has_tag: 1))}.to raise_error ParamContractError
        expect{jobs.send(action, args.merge(has_tag: [1,2,3]))}.to raise_error ParamContractError
        expect{jobs.send(action, args.merge(has_tag: "foo"))}.not_to raise_error ParamContractError
        expect{jobs.send(action, args.merge(has_tag: ["foo", "bar"]))}.not_to raise_error ParamContractError
      end
    end

    context "lacks_tag" do
      it "must be a String or Array[String]" do
        expect{jobs.send(action, args.merge(lacks_tag: nil))}.to raise_error ParamContractError
        expect{jobs.send(action, args.merge(lacks_tag: 1.234))}.to raise_error ParamContractError
        expect{jobs.send(action, args.merge(lacks_tag: -1))}.to raise_error ParamContractError
        expect{jobs.send(action, args.merge(lacks_tag: 1))}.to raise_error ParamContractError
        expect{jobs.send(action, args.merge(lacks_tag: [1,2,3]))}.to raise_error ParamContractError
        expect{jobs.send(action, args.merge(lacks_tag: "foo"))}.not_to raise_error ParamContractError
        expect{jobs.send(action, args.merge(lacks_tag: ["foo", "bar"]))}.not_to raise_error ParamContractError
      end
    end
  end

  context "#schedule" do
    let(:action) { :schedule }
    let(:args)   { {project: 1, spider: "foo"} }

    it_behaves_like "disallows_unknown_keys"

    context "valid arguments" do
      it "passes argument validation" do
        expect{jobs.send(action, args)}.not_to raise_error ParamContractError
      end
    end

    context "project" do
      it "is required" do
        expect{jobs.send(action, args.reject{|k,_| k == :project})}.to raise_error ParamContractError
      end

      it "must be a natural number" do
        expect{jobs.send(action, args.merge(project: nil))}.to raise_error ParamContractError
        expect{jobs.send(action, args.merge(project: "foo"))}.to raise_error ParamContractError
        expect{jobs.send(action, args.merge(project: 1.234))}.to raise_error ParamContractError
        expect{jobs.send(action, args.merge(project: -1))}.to raise_error ParamContractError
        expect{jobs.send(action, args.merge(project: 1))}.not_to raise_error ParamContractError
      end
    end

    context "spider" do
      it "is required" do
        expect{jobs.send(action, args.reject{|k,_| k == :spider})}.to raise_error ParamContractError
      end

      it "must be a String" do
        expect{jobs.send(action, args.merge(spider: nil))}.to raise_error ParamContractError
        expect{jobs.send(action, args.merge(spider: 1.234))}.to raise_error ParamContractError
        expect{jobs.send(action, args.merge(spider: -1))}.to raise_error ParamContractError
        expect{jobs.send(action, args.merge(spider: 1))}.to raise_error ParamContractError
        expect{jobs.send(action, args.merge(spider: "foo"))}.not_to raise_error ParamContractError
      end
    end

    context "add_tag" do
      it "must be a String or Array[String]" do
        expect{jobs.send(action, args.merge(add_tag: nil))}.to raise_error ParamContractError
        expect{jobs.send(action, args.merge(add_tag: 1.234))}.to raise_error ParamContractError
        expect{jobs.send(action, args.merge(add_tag: -1))}.to raise_error ParamContractError
        expect{jobs.send(action, args.merge(add_tag: 1))}.to raise_error ParamContractError
        expect{jobs.send(action, args.merge(add_tag: [1,2,3]))}.to raise_error ParamContractError
        expect{jobs.send(action, args.merge(add_tag: "foo"))}.not_to raise_error ParamContractError
        expect{jobs.send(action, args.merge(add_tag: ["foo", "bar"]))}.not_to raise_error ParamContractError
      end
    end

    context "priority" do
      it "must be 0, 1, 2, 3, or 4" do
        expect{jobs.send(action, args.merge(priority: nil))}.to raise_error ParamContractError
        expect{jobs.send(action, args.merge(priority: 1.234))}.to raise_error ParamContractError
        expect{jobs.send(action, args.merge(priority: -1))}.to raise_error ParamContractError
        expect{jobs.send(action, args.merge(priority: 5))}.to raise_error ParamContractError
        expect{jobs.send(action, args.merge(priority: "foo"))}.to raise_error ParamContractError
        expect{jobs.send(action, args.merge(priority: []))}.to raise_error ParamContractError
      end
    end

    context "extra" do
      it "must be a HashOf[Symbol => String]" do
        expect{jobs.send(action, args.merge(extra: nil))}.to raise_error ParamContractError
        expect{jobs.send(action, args.merge(extra: 1.234))}.to raise_error ParamContractError
        expect{jobs.send(action, args.merge(extra: -1))}.to raise_error ParamContractError
        expect{jobs.send(action, args.merge(extra: 5))}.to raise_error ParamContractError
        expect{jobs.send(action, args.merge(extra: "foo"))}.to raise_error ParamContractError
        expect{jobs.send(action, args.merge(extra: []))}.to raise_error ParamContractError
        expect{jobs.send(action, args.merge(extra: {"foo" => "bar"}))}.to raise_error ParamContractError
        expect{jobs.send(action, args.merge(extra: {foo: 1}))}.to raise_error ParamContractError
      end
    end
  end

end
