FactoryBot.define do
  factory :salary_record do
    association :employee

    amount { 100_000.00 }
    currency { "USD" }
    effective_date { Date.current }
  end
end