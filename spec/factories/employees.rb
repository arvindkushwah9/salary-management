FactoryBot.define do
  factory :employee do
    sequence(:employee_code) { |n| "EMP-#{n.to_s.rjust(5, "0")}" }
    sequence(:email) { |n| "employee#{n}@example.com" }

    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }

    association :department

    designation { "Software Engineer" }
    country { "US" }
    status { "active" }
    joined_date { Date.current }
  end
end