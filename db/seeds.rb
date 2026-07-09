# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Seed default alert rules for development
# Only the error-level rule is enabled by default; the rest are templates you can enable.

# Remove any rules that are no longer in the seed list (e.g. old "Critical Error Detected")
AlertRule.where.not(name: %w[
  Error Log Detected Warning Threshold Known Error Code Match Hostname Contains 'prod'
]).destroy_all

rules = [
  {
    name: "Error Log Detected",
    description: "Triggered when a log entry has level 'error'",
    field: "level",
    operator: "eq",
    value: "error",
    severity: "critical",
    cooldown_minutes: 5,
    enabled: true
  },
  {
    name: "Warning Threshold",
    description: "Triggered when a log entry has level 'warn'",
    field: "level",
    operator: "eq",
    value: "warn",
    severity: "medium",
    cooldown_minutes: 2,
    enabled: false
  },
  {
    name: "Known Error Code Match",
    description: "Triggered when a log entry matches a specific error code",
    field: "error_code",
    operator: "eq",
    value: "TIMEOUT_500",
    severity: "high",
    cooldown_minutes: 3,
    enabled: false
  },
  {
    name: "Hostname Contains 'prod'",
    description: "Triggered when a log entry from production hosts has a specific error_code",
    field: "hostname",
    operator: "contains",
    value: "prod",
    severity: "low",
    cooldown_minutes: 1,
    enabled: false
  }
]

rules.each do |attrs|
  rule = AlertRule.find_or_initialize_by(name: attrs[:name])
  rule.update!(attrs)
end

puts "Seeded #{AlertRule.count} alert rules."
