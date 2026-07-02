class Log < ApplicationRecord
  belongs_to :service

  enum :level, {
    debug: "debug",
    info: "info",
    warn: "warn",
    error: "error",
    critical: "critical"
  }, default: "info"

  validates :level, inclusion: { in: levels.keys }
  validates :message, presence: true
  validates :timestamp, presence: true

  scope :by_level, ->(level) { where(level: level) }
  scope :by_levels, ->(levels) { where(level: levels) }
  scope :by_service, ->(service_name) { joins(:service).where(services: { name: service_name }) }
  scope :by_hostname, ->(hostname) { where(hostname: hostname) }
  scope :by_error_code, ->(code) { where(error_code: code) }
  scope :search_message, ->(query) { where("message ILIKE ?", "%#{sanitize_sql_like(query)}%") }
  scope :since, ->(from) { where("timestamp >= ?", from) }
  scope :until, ->(to) { where("timestamp <= ?", to) }
  scope :recent, -> { order(timestamp: :desc) }
end
