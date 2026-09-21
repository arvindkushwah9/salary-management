class Payslip < ApplicationRecord
  PAYMENT_STATUSES = %w[pending paid failed].freeze

  belongs_to :payroll_run
  belongs_to :employee

  has_many :payslip_items,
           dependent: :restrict_with_error

  validates :working_days,
            presence: true,
            numericality: {
              only_integer: true,
              greater_than: 0
            }

  validates :paid_days,
            presence: true,
            numericality: {
              greater_than_or_equal_to: 0
            }

  validates :gross_earnings,
            :total_deductions,
            :net_pay,
            numericality: {
              greater_than_or_equal_to: 0
            }

  validates :payment_status,
            presence: true,
            inclusion: {
              in: PAYMENT_STATUSES
            }

  validates :employee_id,
            uniqueness: {
              scope: :payroll_run_id,
              message: "already has a payslip for this payroll run"
            }

  validate :paid_days_cannot_exceed_working_days

  def recalculate_totals!
    deductions = payslip_items
      .where(item_type: %w[deduction statutory])
      .sum(:amount)

    update!(
      total_deductions: deductions,
      net_pay: gross_earnings - deductions
    )
  end

  private

  def paid_days_cannot_exceed_working_days
    return if paid_days.blank? || working_days.blank?

    if paid_days > working_days
      errors.add(:paid_days, "cannot exceed working_days")
    end
  end
end