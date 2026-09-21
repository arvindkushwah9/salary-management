FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "hr#{n}@example.com" }
    password { "Password123!" }
    role { "hr_manager" }
  end
end