FactoryBot.define do
  factory :log do
    service { nil }
    level { "MyString" }
    message { "MyText" }
    hostname { "MyString" }
    error_code { "MyString" }
    metadata { "" }
  end
end
