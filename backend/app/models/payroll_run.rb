class PayrollRun < ApplicationRecord
  STATUSES = %w[draft processing approved disbursed].freeze

  has_many :payslips, dependent: :restrict_with_error
  has_many :employees, through: :payslips

  validates :payroll_period,
            presence: true,
            format: {
              with: /\A\d{4}-(0[1-9]|1[0-2])\z/,
              message: "must be in YYYY-MM format"
            }

  validates :payroll_period,
            uniqueness: {
              scope: :currency,
              message: "already exists for this currency"
            }

  validates :currency,
            presence: true,
            length: { is: 3 },
            format: {
              with: /\A[A-Z]{3}\z/,
              message: "must be a valid 3-letter currency code"
            }

  validates :status,
            presence: true,
            inclusion: { in: STATUSES }

  validates :total_gross,
            :total_deductions,
            :total_net,
            numericality: { greater_than_or_equal_to: 0 }
            
  def recalculate_totals!
    update!(
      total_gross: payslips.sum(:gross_earnings),
      total_deductions: payslips.sum(:total_deductions),
      total_net: payslips.sum(:net_pay)
    )
  end
end