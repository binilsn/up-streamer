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
    ActionCable.server.broadcast("dashboard_metrics", {
      ingestion_rate_kbps: MetricsTracker.ingestion_rate_kbps,
      events_per_sec: MetricsTracker.events_per_sec,
      memory_used_mb: MetricsTracker.process_memory_mb,
      memory_total_mb: MetricsTracker.system_memory_total_mb,
      cpu_pct: MetricsTracker.process_cpu_pct,
      active_alerts: Alert.active.count,
      uptime: MetricsTracker.server_uptime
    })
  end
end
