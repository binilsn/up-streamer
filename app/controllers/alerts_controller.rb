class AlertsController < ApplicationController
  def index
    @alerts = Alert.recent.includes(:alert_rule, :service)

    @alerts = @alerts.by_severity(params[:severity]) if params[:severity].present?
    @alerts = @alerts.where(status: params[:status]) if params[:status].present?

    @active_count = Alert.active.count
    @total_count = Alert.count
    @severity_counts = Alert.group(:severity).count
    @status_counts = Alert.group(:status).count

    @pagy, @alerts = pagy(@alerts, items: params[:per_page]&.to_i || 25, max_items: 100)
  end

  def acknowledge
    alert = Alert.find(params[:id])
    alert.acknowledge!
    redirect_to alerts_path, notice: "Alert acknowledged."
  end

  def resolve
    alert = Alert.find(params[:id])
    alert.resolve!
    redirect_to alerts_path, notice: "Alert resolved."
  end
end
