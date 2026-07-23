class DashboardController < ApplicationController
  def index
    @total_logs_24h = Log.since(24.hours.ago).count
    @total_logs_trend = compute_trend
  end

  private

  def compute_trend
    current = Log.since(24.hours.ago).count
    previous = Log.since(48.hours.ago).until(24.hours.ago).count
    return 0.0 if previous.zero?
    ((current - previous).to_f / previous * 100).round(1)
  end
end
