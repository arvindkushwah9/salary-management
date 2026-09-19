FactoryBot.define do
  factory :employee do
    sequence(:employee_number) { |n| "EMP-#{n.to_s.rjust(5, "0")}" }
    sequence(:email) { |n| "employee#{n}@example.com" }

    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    country { "US" }
    department { "Engineering" }
    job_title { "Software Engineer" }
    employment_status { "active" }
  end
end