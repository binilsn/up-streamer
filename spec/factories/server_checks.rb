FactoryBot.define do
  factory :server_check do
    service
    status { "up" }
    response_time_ms { 42 }
    ssl_valid { true }
    ssl_expires_at { 90.days.from_now }
    ssl_issuer { "Let's Encrypt" }
    checked_at { Time.current }
    metadata { { region: "us-east-1" } }
  end
end
