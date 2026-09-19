FactoryBot.define do
  factory :salary_record do
    employee { nil }
    amount { "9.99" }
    currency { "MyString" }
    effective_date { "2026-09-19" }
  end
end
