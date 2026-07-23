class Service < ApplicationRecord
  has_secure_token :access_token
  has_many :logs, dependent: :destroy
  has_many :alert_rules, dependent: :destroy
  has_many :alerts, dependent: :destroy
  has_many :server_checks, dependent: :delete_all

  before_create :set_defaults

  validates :name, presence: true, uniqueness: true

  scope :active, -> { where(active: true) }

  private

  def set_defaults
    self.active = true if active.nil?
  end
end
