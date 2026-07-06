FactoryBot.define do
  factory :log do
    service
    level { %w[debug info warn error critical].sample }
    message { Faker::Lorem.sentence }
    hostname { Faker::Internet.domain_name }
    error_code { nil }
    metadata { {} }
    timestamp { Time.current }
  end
end
