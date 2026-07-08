require "rails_helper"

RSpec.describe LogSearchParser do
  subject(:result) { described_class.new(query).call }

  describe "#call" do
    context "with a plain text query" do
      let(:query) { "hello world" }

      it "returns no structured filters" do
        expect(result.filters).to be_empty
      end

      it "returns the full query as plain text" do
        expect(result.plain_text).to eq("hello world")
      end
    end

    context "with a single structured filter" do
      let(:query) { "level:error" }

      it "parses the filter", :aggregate_failures do
        expect(result.filters.length).to eq(1)
        expect(result.filters[0].field).to eq("level")
        expect(result.filters[0].operator).to eq("=")
        expect(result.filters[0].value).to eq("error")
      end

      it "returns empty plain text" do
        expect(result.plain_text).to be_empty
      end
    end

    context "with multiple structured filters" do
      let(:query) { "level:error host:web-01 service:api" }

      it "parses all filters", :aggregate_failures do
        expect(result.filters.length).to eq(3)
        expect(result.filters.map(&:field)).to match_array(%w[level host service])
      end

      it "returns empty plain text" do
        expect(result.plain_text).to be_empty
      end
    end

    context "with mixed structured and plain text" do
      let(:query) { "level:error timeout for database" }

      it "extracts structured filters", :aggregate_failures do
        expect(result.filters.length).to eq(1)
        expect(result.filters[0].field).to eq("level")
      end

      it "returns remaining text as plain text" do
        expect(result.plain_text).to eq("timeout for database")
      end
    end

    context "with quoted values" do
      let(:query) { 'message:"connection timeout" level:error' }

      it "handles quoted values" do
        message_filter = result.filters.find { |f| f.field == "message" }
        expect(message_filter.value).to eq("connection timeout")
      end

      it "parses other filters normally" do
        level_filter = result.filters.find { |f| f.field == "level" }
        expect(level_filter.value).to eq("error")
      end
    end

    context "with comparison operators" do
      let(:query) { "duration:>500" }

      it "extracts the operator", :aggregate_failures do
        expect(result.filters[0].operator).to eq(">")
        expect(result.filters[0].value).to eq("500")
      end
    end

    context "with >= and <= operators" do
      let(:query) { "duration:>=1000 duration:<=5000" }

      it "extracts >= operator", :aggregate_failures do
        expect(result.filters[0].operator).to eq(">=")
        expect(result.filters[0].value).to eq("1000")
      end

      it "extracts <= operator", :aggregate_failures do
        expect(result.filters[1].operator).to eq("<=")
        expect(result.filters[1].value).to eq("5000")
      end
    end

    context "with duration:< operator" do
      let(:query) { "duration:<100" }

      it "extracts the operator", :aggregate_failures do
        expect(result.filters[0].operator).to eq("<")
        expect(result.filters[0].value).to eq("100")
      end
    end

    context "with unknown field names" do
      let(:query) { "unknown:value level:info" }

      it "treats unknown fields as plain text" do
        expect(result.plain_text).to include("unknown:value")
      end

      it "still parses known fields", :aggregate_failures do
        expect(result.filters.length).to eq(1)
        expect(result.filters[0].field).to eq("level")
      end
    end

    context "with tag field" do
      let(:query) { "tag:payments" }

      it "parses tag filter", :aggregate_failures do
        expect(result.filters[0].field).to eq("tag")
        expect(result.filters[0].value).to eq("payments")
      end
    end

    context "with trace_id and request_id" do
      let(:query) { "trace_id:abc123 request_id:req_456" }

      it "parses both filters", :aggregate_failures do
        expect(result.filters.length).to eq(2)
        expect(result.filters.map(&:field)).to match_array(%w[trace_id request_id])
      end
    end

    context "with an empty query" do
      let(:query) { "" }

      it "returns no filters" do
        expect(result.filters).to be_empty
      end

      it "returns empty plain text" do
        expect(result.plain_text).to be_empty
      end
    end

    context "with nil query" do
      let(:query) { nil }

      it "handles nil gracefully", :aggregate_failures do
        expect(result.filters).to be_empty
        expect(result.plain_text).to be_empty
      end
    end
  end

  describe "#any?" do
    context "when there are filters" do
      let(:query) { "level:error" }

      it "returns true" do
        expect(result).to be_any
      end
    end

    context "when there are no filters" do
      let(:query) { "plain text" }

      it "returns false" do
        expect(result).not_to be_any
      end
    end
  end
end
