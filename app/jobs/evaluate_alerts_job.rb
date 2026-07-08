class EvaluateAlertsJob < ApplicationJob
  queue_as :default

  def perform(log_id)
    log = Log.find_by(id: log_id)
    return unless log

    AlertEvaluationService.new(log: log).call
  end
end
