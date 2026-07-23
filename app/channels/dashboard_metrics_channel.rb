class DashboardMetricsChannel < ApplicationCable::Channel
  periodically :broadcast_metrics, every: 1.second

  def subscribed
    stream_from "dashboard_metrics"
  end

  def unsubscribed
    # Cleanup handled by Action Cable
  end

  private

  def broadcast_metrics
    current_24h = Log.since(24.hours.ago).count
    previous_24h = Log.since(48.hours.ago).until(24.hours.ago).count
    trend_pct = previous_24h.zero? ? 0.0 : ((current_24h - previous_24h).to_f / previous_24h * 100).round(1)

    ActionCable.server.broadcast("dashboard_metrics", {
      ingestion_rate_kbps: MetricsTracker.ingestion_rate_kbps,
      events_per_sec: MetricsTracker.events_per_sec,
      memory_used_mb: MetricsTracker.process_memory_mb,
      memory_total_mb: MetricsTracker.system_memory_total_mb,
      cpu_pct: MetricsTracker.process_cpu_pct,
      active_alerts: Alert.active.count,
      uptime: MetricsTracker.server_uptime,
      total_logs_24h: current_24h,
      total_logs_trend_pct: trend_pct
    })
  end
end
