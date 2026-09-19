FactoryBot.define do
  factory :payroll_run do
    payroll_period { Date.current.strftime("%Y-%m") }
    status { "draft" }
    total_gross { 0 }
    total_deductions { 0 }
    total_net { 0 }
  end
end