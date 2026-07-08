class Alert < ApplicationRecord
  belongs_to :alert_rule
  belongs_to :log, optional: true
  belongs_to :service, optional: true

  has_one :alert_rule_service, through: :alert_rule, source: :service

  SEVERITIES = %w[critical high medium low].freeze
  STATUSES = %w[active acknowledged resolved].freeze

  validates :title, presence: true
  validates :severity, presence: true, inclusion: { in: SEVERITIES }
  validates :status, presence: true, inclusion: { in: STATUSES }
  validates :triggered_at, presence: true

  scope :active, -> { where(status: "active") }
  scope :unresolved, -> { where.not(status: "resolved") }
  scope :recent, -> { order(triggered_at: :desc) }
  scope :by_severity, ->(severity) { where(severity: severity) }
  scope :since, ->(from) { where("triggered_at >= ?", from) }

  def acknowledge!
    update!(status: "acknowledged")
  end

  def resolve!
    update!(status: "resolved", resolved_at: Time.current)
  end
end
