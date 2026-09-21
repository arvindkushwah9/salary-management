class Department < ApplicationRecord
  has_many :employees,
           dependent: :restrict_with_error

  validates :code,
            presence: true,
            uniqueness: true

  validates :name,
            presence: true,
            uniqueness: true

  normalizes :code,
            with: ->(value) { value.to_s.strip.upcase }

  normalizes :name,
            with: ->(value) { value.to_s.strip }
end