FactoryBot.define do
  factory :service do
    name { "MyString" }
    description { "MyText" }
    access_token { "MyString" }
    active { false }
  end
end
