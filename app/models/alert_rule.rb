class AlertRule < ApplicationRecord
  has_many :alerts, dependent: :destroy
  belongs_to :service, optional: true

  SEVERITIES = %w[critical high medium low].freeze
  OPERATORS = %w[eq neq contains].freeze
  FIELDS = %w[level error_code hostname message].freeze

  validates :name, presence: true
  validates :field, presence: true, inclusion: { in: FIELDS }
  validates :operator, presence: true, inclusion: { in: OPERATORS }
  validates :value, presence: true
  validates :severity, presence: true, inclusion: { in: SEVERITIES }
  validates :cooldown_minutes, numericality: { greater_than: 0 }
  validates :level, inclusion: { in: Log.levels.keys }, allow_blank: true

  scope :enabled, -> { where(enabled: true) }
  scope :for_log_level, ->(level) {
    where(level: nil).or(where(level: level))
  }
  scope :for_service, ->(service_id) {
    where(service_id: nil).or(where(service_id: service_id))
  }

  def matches?(log)
    log_value = log.public_send(field)
    return false if log_value.blank?

    case operator
    when "eq"
      log_value == value
    when "neq"
      log_value != value
    when "contains"
      log_value.to_s.downcase.include?(value.to_s.downcase)
    else
      false
    end
  end

  def in_cooldown?
    return false unless last_triggered_at
    last_triggered_at > cooldown_minutes.minutes.ago
  end
end
