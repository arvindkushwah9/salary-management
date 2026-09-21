class User < ApplicationRecord
  has_secure_password

  ROLES = %w[hr_manager].freeze

  validates :email,
            presence: true,
            uniqueness: true,
            format: { with: URI::MailTo::EMAIL_REGEXP }

  validates :role,
            presence: true,
            inclusion: { in: ROLES }

  normalizes :email, with: ->(email) { email.strip.downcase }
end