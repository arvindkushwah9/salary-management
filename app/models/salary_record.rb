class SalaryRecord < ApplicationRecord
  belongs_to :employee

  validates :amount,
            presence: true,
            numericality: { greater_than_or_equal_to: 0 }

  validates :currency,
            presence: true,
            length: { is: 3 },
            format: { with: /\A[A-Z]{3}\z/ }

  validates :effective_date, presence: true

  scope :for_currency, ->(currency) {
    where(currency: currency) if currency.present?
  }

  scope :effective_on_or_before, ->(date) {
    where("effective_date <= ?", date)
  }

  scope :chronological, -> {
    order(effective_date: :asc)
  }

  scope :latest_first, -> {
    order(effective_date: :desc)
  }

  before_validation :normalize_currency

  private

  def normalize_currency
    self.currency = currency.to_s.upcase
  end
end