class Service < ApplicationRecord
  has_secure_token :access_token

  before_create :set_defaults

  validates :name, presence: true, uniqueness: true

  scope :active, -> { where(active: true) }

  private

  def set_defaults
    self.active = true if active.nil?
  end
end
