class Employee < ApplicationRecord
  has_many :salary_records, dependent: :restrict_with_error

  STATUSES = %w[active inactive].freeze

  validates :employee_number, presence: true, uniqueness: true
  validates :first_name, :last_name, :email, :country, presence: true
  validates :email, uniqueness: true,
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :employment_status, inclusion: { in: STATUSES }

  scope :active, -> { where(employment_status: "active") }
  scope :inactive, -> { where(employment_status: "inactive") }
  scope :by_country, ->(country) {
    where(country: country) if country.present?
  }
  scope :by_department, ->(department) {
    where(department: department) if department.present?
  }

  scope :search, ->(term) {
    return all if term.blank?

    pattern = "%#{sanitize_sql_like(term)}%"

    where(
      "employee_number ILIKE :pattern OR
       first_name ILIKE :pattern OR
       last_name ILIKE :pattern OR
       email ILIKE :pattern",
      pattern: pattern
    )
  }

  def full_name
    "#{first_name} #{last_name}"
  end

  def current_salary
    salary_records.current.first
  end
end