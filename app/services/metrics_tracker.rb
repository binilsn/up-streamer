class MetricsTracker
  BUCKET_SIZE = 1.second
  WINDOW_SIZE = 10

  def initialize
    @mutex = Mutex.new
    @buckets = []
  end

  class << self
    def instance
      @instance ||= new
    end

    delegate :record, :events_per_sec, :ingestion_rate_kbps, to: :instance
  end

  def record(bytes)
    now = Time.current.to_i
    bucket_key = now - (now % BUCKET_SIZE)

    @mutex.synchronize do
      prune(now)
      bucket = @buckets.find { |b| b[:key] == bucket_key }
      unless bucket
        bucket = { key: bucket_key, events: 0, bytes: 0 }
        @buckets << bucket
      end
      bucket[:events] += 1
      bucket[:bytes] += bytes
    end
  end

  def events_per_sec
    now = Time.current.to_i
    @mutex.synchronize do
      prune(now)
      return 0 if @buckets.empty?

      total_events = @buckets.sum { |b| b[:events] }
      total_seconds = [ @buckets.length, 1 ].max
      (total_events.to_f / total_seconds).round(1)
    end
  end

  def ingestion_rate_kbps
    now = Time.current.to_i
    @mutex.synchronize do
      prune(now)
      return 0.0 if @buckets.empty?

      total_bytes = @buckets.sum { |b| b[:bytes] }
      total_seconds = [ @buckets.length, 1 ].max
      kbps = (total_bytes.to_f / total_seconds) / 1024
      kbps.round(1)
    end
  end

  private

  def prune(now)
    cutoff = now - WINDOW_SIZE
    @buckets.reject! { |b| b[:key] < cutoff }
  end
end
