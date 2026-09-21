FactoryBot.define do
  factory :salary_structure do
    association :employee

    base_salary { 100_000.00 }
    housing_allowance { 10_000.00 }
    conveyance_allowance { 5_000.00 }
    special_allowance { 5_000.00 }

    currency { "USD" }
    effective_from { Date.current }
    effective_to { nil }
  end
end