class ServerCheck < ApplicationRecord
  belongs_to :service

  STATUSES = %w[up down degraded].freeze

  enum :status, {
    up: "up",
    down: "down",
    degraded: "degraded"
  }, default: "up"

  validates :status, presence: true, inclusion: { in: STATUSES }
  validates :checked_at, presence: true
  validates :response_time_ms, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  scope :recent, -> { order(checked_at: :desc) }
  scope :stale, -> { where("checked_at < ?", 7.days.ago) }
  scope :latest_per_service, -> {
    select("DISTINCT ON (service_id) *")
      .order("service_id, checked_at DESC")
  }
end
