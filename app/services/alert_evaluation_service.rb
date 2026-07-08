class AlertEvaluationService
  Result = Struct.new(:alert_created?, :alert, keyword_init: true)

  def initialize(log:)
    @log = log
    @service = log.service
  end

  def call
    applicable_rules.each do |rule|
      next unless rule.matches?(@log)
      next if rule.in_cooldown?

      alert = create_alert!(rule)
      rule.touch(:last_triggered_at)

      broadcast_alert(alert)

      return Result.new(alert_created?: true, alert: alert)
    end

    Result.new(alert_created?: false, alert: nil)
  end

  private

  def applicable_rules
    AlertRule.enabled
             .for_log_level(@log.level)
             .for_service(@service.id)
  end

  def create_alert!(rule)
    Alert.create!(
      alert_rule: rule,
      log: @log,
      service: @service,
      title: rule.name,
      description: alert_description(rule),
      severity: rule.severity,
      status: "active",
      triggered_at: Time.current,
      metadata: {
        log_id: @log.id,
        log_level: @log.level,
        log_message: @log.message.truncate(200),
        matched_field: rule.field,
        matched_value: @log.public_send(rule.field)
      }
    )
  end

  def alert_description(rule)
    log_value = @log.public_send(rule.field)
    "Rule '#{rule.name}' matched: #{rule.field} #{rule.operator} '#{rule.value}' (actual: '#{log_value}')"
  end

  def broadcast_alert(alert)
    payload = {
      id: alert.id,
      title: alert.title,
      description: alert.description,
      severity: alert.severity,
      status: alert.status,
      triggered_at: alert.triggered_at.iso8601(3),
      service: @service.name,
      log_id: @log.id,
      log_level: @log.level,
      log_message: @log.message.truncate(200)
    }

    ActionCable.server.broadcast("alerts", payload)
  end
end
