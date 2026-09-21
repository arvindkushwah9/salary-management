class SalaryStructure < ApplicationRecord
  belongs_to :employee

  validates :base_salary,
            presence: true,
            numericality: { greater_than_or_equal_to: 0 }

  validates :housing_allowance,
            numericality: { greater_than_or_equal_to: 0 }

  validates :conveyance_allowance,
            numericality: { greater_than_or_equal_to: 0 }

  validates :special_allowance,
            numericality: { greater_than_or_equal_to: 0 }

  validates :currency,
            presence: true,
            length: { is: 3 },
            format: { with: /\A[A-Z]{3}\z/ }

  validates :effective_from, presence: true

  validate :effective_to_after_effective_from

  scope :for_currency, ->(currency) {
    where(currency: currency) if currency.present?
  }

  scope :effective_on_or_before, ->(date) {
    where("effective_from <= ?", date)
  }

  scope :chronological, -> {
    order(effective_from: :asc)
  }

  scope :latest_first, -> {
    order(effective_from: :desc)
  }

  scope :current, ->(date = Date.current) {
    where("effective_from <= ?", date)
      .where("effective_to IS NULL OR effective_to >= ?", date)
      .order(effective_from: :desc)
  }

  def gross_salary
    base_salary +
      housing_allowance +
      conveyance_allowance +
      special_allowance
  end

  private

  def effective_to_after_effective_from
    return if effective_to.blank? || effective_from.blank?

    if effective_to < effective_from
      errors.add(:effective_to, "must be on or after effective_from")
    end
  end
end