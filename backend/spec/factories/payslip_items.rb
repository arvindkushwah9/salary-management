FactoryBot.define do
  factory :payslip_item do
    association :payslip

    item_type { "earning" }
    code { "BASIC" }
    description { "Base salary" }
    amount { 100_000.00 }
  end
end