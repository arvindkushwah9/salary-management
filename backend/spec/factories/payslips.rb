FactoryBot.define do
  factory :payslip do
    association :payroll_run
    association :employee

    working_days { 30 }
    paid_days { 30.0 }
    gross_earnings { 120_000.00 }
    total_deductions { 0.00 }
    net_pay { 120_000.00 }
    payment_status { "pending" }
    payslip_pdf_url { nil }
  end
end