require "sys/proctable"

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

    delegate :record, :events_per_sec, :ingestion_rate_kbps, :process_memory_mb,
             :system_memory_total_mb, :system_memory_used_mb, :process_cpu_pct, to: :instance
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

  # --- System Resource Metrics ---

  def process_memory_mb
    ps = Sys::ProcTable.ps(pid: Process.pid)
    # RSS is reported in pages (4096 bytes per page on x86_64)
    rss_bytes = ps.rss * 4096
    (rss_bytes.to_f / 1024 / 1024).round(1)
  rescue => e
    Rails.logger.warn("[MetricsTracker] Failed to get process memory: #{e.message}")
    0.0
  end

  def system_memory_total_mb
    kb = read_meminfo("MemTotal")
    (kb.to_f / 1024).round(1)
  end

  def system_memory_used_mb
    total = read_meminfo("MemTotal")
    avail = read_meminfo("MemAvailable")
    [ ((total - avail).to_f / 1024).round(1), 0.0 ].max
  end

  def process_cpu_pct
    ps = Sys::ProcTable.ps(pid: Process.pid)
    ps.pctcpu.to_f.round(1)
  rescue => e
    Rails.logger.warn("[MetricsTracker] Failed to get process CPU: #{e.message}")
    0.0
  end

  private

  def read_meminfo(key)
    File.readlines("/proc/meminfo").each do |line|
      if line.start_with?(key)
        return line.scan(/\d+/).first.to_i
      end
    end
    0
  rescue Errno::ENOENT, Errno::EACCES => e
    Rails.logger.warn("[MetricsTracker] Failed to read /proc/meminfo: #{e.message}")
    0
  end

  def prune(now)
    cutoff = now - WINDOW_SIZE
    @buckets.reject! { |b| b[:key] < cutoff }
  end
end
