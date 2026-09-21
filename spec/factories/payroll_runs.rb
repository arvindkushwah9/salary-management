FactoryBot.define do
  factory :payroll_run do
    sequence(:payroll_period) do |n|
      month = ((n - 1) % 12) + 1
      year = Date.current.year + ((n - 1) / 12)

      format(
        "%<year>04d-%<month>02d",
        year: year,
        month: month
      )
    end

    currency { "USD" }
    status { "draft" }

    total_gross { 0 }
    total_deductions { 0 }
    total_net { 0 }
  end
end