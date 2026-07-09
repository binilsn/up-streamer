class AlertRulesController < ApplicationController
  before_action :set_alert_rule, only: [ :edit, :update, :destroy, :toggle ]

  def index
    @alert_rules = AlertRule.all.order(created_at: :desc)
    @alert_rule = AlertRule.new
    @services = Service.all.order(:name)
  end

  def new
    @alert_rule = AlertRule.new
    @services = Service.all.order(:name)
  end

  def create
    @alert_rule = AlertRule.new(alert_rule_params)

    if @alert_rule.save
      redirect_to alert_rules_path, notice: "Rule '#{@alert_rule.name}' created."
    else
      @alert_rules = AlertRule.all.order(created_at: :desc)
      @services = Service.all.order(:name)
      render :index, status: :unprocessable_entity
    end
  end

  def edit
    @services = Service.all.order(:name)
  end

  def update
    if @alert_rule.update(alert_rule_params)
      redirect_to alert_rules_path, notice: "Rule '#{@alert_rule.name}' updated."
    else
      @services = Service.all.order(:name)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @alert_rule.destroy!
    redirect_to alert_rules_path, notice: "Rule '#{@alert_rule.name}' deleted."
  end

  def toggle
    @alert_rule.update!(enabled: !@alert_rule.enabled)
    redirect_to alert_rules_path, notice: "Rule '#{@alert_rule.name}' #{@alert_rule.enabled? ? 'enabled' : 'disabled'}."
  end

  private

  def set_alert_rule
    @alert_rule = AlertRule.find(params[:id])
  end

  def alert_rule_params
    params.require(:alert_rule).permit(
      :name, :description, :service_id, :level, :field,
      :operator, :value, :severity, :cooldown_minutes, :enabled
    )
  end
end
