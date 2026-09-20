class Employee < ApplicationRecord
  belongs_to :department

  has_many :salary_structures,
           dependent: :restrict_with_error

  has_many :payslips,
           dependent: :restrict_with_error
  

  STATUSES = %w[active terminated on_leave].freeze


  validates :employee_code,
            presence: true,
            uniqueness: true

  validates :first_name,
            :last_name,
            :email,
            :country,
            :designation,
            :status,
            :joined_date,
            presence: true

  validates :email,
            uniqueness: true,
            format: {
              with: URI::MailTo::EMAIL_REGEXP
            }

  validates :status,
            inclusion: {
              in: STATUSES
            }

  scope :active, -> { where(status: "active") }
  scope :inactive, -> { where.not(status: "active") }
  scope :terminated, -> { where(status: "terminated") }
  scope :on_leave, -> { where(status: "on_leave") }

  scope :by_country, ->(country) {
    where(country: country) if country.present?
  }

  scope :by_department, ->(department_id) {
    where(department_id: department_id) if department_id.present?
  }

  scope :by_status, ->(status) {
    where(status: status) if status.present?
  }

  scope :search, ->(term) {
    return all if term.blank?

    pattern = "%#{sanitize_sql_like(term)}%"

    where(
      "employee_code ILIKE :pattern OR
       first_name ILIKE :pattern OR
       last_name ILIKE :pattern OR
       email ILIKE :pattern OR
       designation ILIKE :pattern",
      pattern: pattern
    )
  }

  def full_name
    "#{first_name} #{last_name}"
  end

  def current_salary
    salary_structures
      .where("effective_from <= ?", Date.current)
      .where("effective_to IS NULL OR effective_to >= ?", Date.current)
      .order(effective_from: :desc)
      .first
  end
end