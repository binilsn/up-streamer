require "rails_helper"

RSpec.describe LogQuery do
  before do
    Log.delete_all
    Service.delete_all
  end

  let(:service) { create(:service, name: "api") }
  let(:other_service) { create(:service, name: "web") }

  let!(:error_log) do
    create(:log,
      service: service,
      level: "error",
      hostname: "web-01",
      message: "Connection timeout to database",
      metadata: { status: 500, duration: 1200, env: "production", path: "/api/users", trace_id: "abc123", request_id: "req_001" },
      timestamp: 1.minute.ago
    )
  end

  let!(:info_log) do
    create(:log,
      service: other_service,
      level: "info",
      hostname: "web-02",
      message: "Request completed successfully",
      metadata: { status: 200, duration: 45, env: "staging", path: "/api/health", trace_id: "def456", request_id: "req_002" },
      timestamp: 2.minutes.ago
    )
  end

  let!(:warn_log) do
    create(:log,
      service: service,
      level: "warn",
      hostname: "web-01",
      message: "Slow query detected",
      metadata: { status: 200, duration: 600, env: "production", path: "/api/health", trace_id: "ghi789", request_id: "req_003", tags: [ "payments", "db" ] },
      timestamp: 3.minutes.ago
    )
  end

  describe "#call with structured search" do
    it "filters by level via structured query" do
      logs = described_class.new(Log.all, { q: "level:error" }).call
      expect(logs).to contain_exactly(error_log)
    end

    it "filters by host via structured query" do
      logs = described_class.new(Log.all, { q: "host:web-01" }).call
      expect(logs).to contain_exactly(error_log, warn_log)
    end

    it "filters by service via structured query" do
      logs = described_class.new(Log.all, { q: "service:api" }).call
      expect(logs).to contain_exactly(error_log, warn_log)
    end

    it "filters by error_code via structured query" do
      error_log.update!(error_code: "ERR_500")
      logs = described_class.new(Log.all, { q: "error_code:ERR_500" }).call
      expect(logs).to contain_exactly(error_log)
    end

    it "filters by metadata status via structured query" do
      logs = described_class.new(Log.all, { q: "status:500" }).call
      expect(logs).to contain_exactly(error_log)
    end

    it "filters by metadata env via structured query" do
      logs = described_class.new(Log.all, { q: "env:production" }).call
      expect(logs).to contain_exactly(error_log, warn_log)
    end

    it "filters by metadata path via structured query" do
      logs = described_class.new(Log.all, { q: "path:/api/users" }).call
      expect(logs).to contain_exactly(error_log)
    end

    it "filters by trace_id via structured query" do
      logs = described_class.new(Log.all, { q: "trace_id:abc123" }).call
      expect(logs).to contain_exactly(error_log)
    end

    it "filters by request_id via structured query" do
      logs = described_class.new(Log.all, { q: "request_id:req_001" }).call
      expect(logs).to contain_exactly(error_log)
    end

    it "filters by tag via structured query" do
      logs = described_class.new(Log.all, { q: "tag:payments" }).call
      expect(logs).to contain_exactly(warn_log)
    end

    it "filters by duration with > operator" do
      logs = described_class.new(Log.all, { q: "duration:>1000" }).call
      expect(logs).to contain_exactly(error_log)
    end

    it "filters by duration with < operator" do
      logs = described_class.new(Log.all, { q: "duration:<100" }).call
      expect(logs).to contain_exactly(info_log)
    end

    it "filters by duration with >= operator" do
      logs = described_class.new(Log.all, { q: "duration:>=600" }).call
      expect(logs).to contain_exactly(error_log, warn_log)
    end

    it "filters by duration with <= operator" do
      logs = described_class.new(Log.all, { q: "duration:<=45" }).call
      expect(logs).to contain_exactly(info_log)
    end

    it "combines multiple structured filters" do
      logs = described_class.new(Log.all, { q: "service:api host:web-01" }).call
      expect(logs).to contain_exactly(error_log, warn_log)
    end

    it "combines structured filter with plain text search" do
      logs = described_class.new(Log.all, { q: "service:api timeout" }).call
      expect(logs).to contain_exactly(error_log)
    end

    it "filters by quoted message" do
      logs = described_class.new(Log.all, { q: 'message:"Connection timeout"' }).call
      expect(logs).to contain_exactly(error_log)
    end

    it "falls through to plain text search for unrecognized fields" do
      logs = described_class.new(Log.all, { q: "Slow query" }).call
      expect(logs).to contain_exactly(warn_log)
    end

    it "returns all logs when query is empty" do
      logs = described_class.new(Log.all, { q: "" }).call
      expect(logs).to contain_exactly(error_log, info_log, warn_log)
    end

    it "returns all logs when no query is given" do
      logs = described_class.new(Log.all, {}).call
      expect(logs).to contain_exactly(error_log, info_log, warn_log)
    end
  end
end
