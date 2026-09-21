class PayslipItem < ApplicationRecord
  ITEM_TYPES = %w[
    earning
    deduction
    statutory
  ].freeze

  belongs_to :payslip

  validates :item_type,
            presence: true,
            inclusion: {
              in: ITEM_TYPES
            }

  validates :code,
            presence: true,
            length: {
              maximum: 30
            }

  validates :description,
            length: {
              maximum: 100
            }

  validates :amount,
            presence: true,
            numericality: {
              greater_than_or_equal_to: 0
            }
end