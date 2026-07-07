FactoryBot.define do
  factory :service do
    name { Faker::App.name }
    description { Faker::Lorem.sentence }
    access_token { SecureRandom.hex(32) }
    active { true }
  end
end
