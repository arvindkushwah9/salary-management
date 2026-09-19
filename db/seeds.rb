# db/seeds.rb

# Salary Management demo dataset.
#
# Creates:
# - 10,000 employees
# - 7 departments
# - 1 current salary structure per employee
# - salary history for approximately 30% of employees
# - 1 HR manager
#
# Run with:
#   bin/rails db:seed

require "faker"

EMPLOYEE_COUNT = 10_000
BATCH_SIZE = 1_000

puts "Starting salary management seed..."

# ------------------------------------------------------------
# Deterministic random data
# ------------------------------------------------------------

RANDOM = Random.new(42)

Faker::Config.random = RANDOM

# ------------------------------------------------------------
# Departments
# ------------------------------------------------------------

DEPARTMENT_DATA = [
  ["ENG", "Engineering"],
  ["PROD", "Product"],
  ["SALES", "Sales"],
  ["MKT", "Marketing"],
  ["FIN", "Finance"],
  ["HR", "Human Resources"],
  ["OPS", "Operations"]
].freeze

puts "Creating departments..."

departments = {}

DEPARTMENT_DATA.each do |code, name|
  department = Department.find_or_create_by!(code: code) do |record|
    record.name = name
  end

  departments[name] = department
end

puts "  Departments: #{Department.count}"

# ------------------------------------------------------------
# HR user
# ------------------------------------------------------------

puts "Creating HR manager..."

User.find_or_create_by!(email: "hr@example.com") do |user|
  user.password = "Password123!"
  user.role = "hr_manager"
end

# ------------------------------------------------------------
# Countries
# ------------------------------------------------------------

COUNTRIES = {
  "US" => {
    currency: "USD",
    salary_range: 70_000..180_000
  },
  "UK" => {
    currency: "GBP",
    salary_range: 45_000..120_000
  },
  "IN" => {
    currency: "INR",
    salary_range: 1_200_000..5_000_000
  },
  "DE" => {
    currency: "EUR",
    salary_range: 50_000..130_000
  },
  "CA" => {
    currency: "CAD",
    salary_range: 65_000..160_000
  },
  "AU" => {
    currency: "AUD",
    salary_range: 75_000..180_000
  },
  "SG" => {
    currency: "SGD",
    salary_range: 65_000..170_000
  },
  "NL" => {
    currency: "EUR",
    salary_range: 50_000..125_000
  }
}.freeze

# ------------------------------------------------------------
# Job titles
# ------------------------------------------------------------

JOB_TITLES = {
  "Engineering" => [
    "Software Engineer",
    "Senior Software Engineer",
    "Staff Software Engineer",
    "Engineering Manager"
  ],

  "Product" => [
    "Product Manager",
    "Senior Product Manager",
    "Product Owner"
  ],

  "Sales" => [
    "Sales Executive",
    "Account Executive",
    "Sales Manager"
  ],

  "Marketing" => [
    "Marketing Specialist",
    "Marketing Manager",
    "Content Strategist"
  ],

  "Finance" => [
    "Financial Analyst",
    "Senior Financial Analyst",
    "Finance Manager"
  ],

  "Human Resources" => [
    "HR Specialist",
    "HR Business Partner",
    "HR Manager"
  ],

  "Operations" => [
    "Operations Specialist",
    "Operations Manager",
    "Operations Director"
  ]
}.freeze

# ------------------------------------------------------------
# Existing data cleanup
# ------------------------------------------------------------

puts "Cleaning existing demo data..."

# We are rebuilding the local/demo database.
# Keep users/departments and rebuild employees and compensation.
SalaryStructure.delete_all if defined?(SalaryStructure)
Employee.delete_all

puts "  Existing employees removed."

# ------------------------------------------------------------
# Employees
# ------------------------------------------------------------

puts "Creating #{EMPLOYEE_COUNT} employees..."

employee_rows = []

EMPLOYEE_COUNT.times do |index|
  employee_code = index + 1

  country, country_config = COUNTRIES.to_a.sample(
    random: RANDOM
  )

  department_name = DEPARTMENT_DATA
    .map(&:last)
    .sample(random: RANDOM)

  first_name = Faker::Name.first_name
  last_name = Faker::Name.last_name

  joined_date = Date.new(
    RANDOM.rand(2018..2025),
    RANDOM.rand(1..12),
    1
  )

  status =
    case employee_code % 20
    when 0
      "active"
    when 1
      "on_leave"
    else
      "terminated"
    end

  employee_rows << {
    employee_code: "EMP-#{employee_code.to_s.rjust(5, "0")}",
    first_name: first_name,
    last_name: last_name,
    email: "employee#{employee_code}@example.com",

    department_id: departments.fetch(department_name).id,

    designation: JOB_TITLES
      .fetch(department_name)
      .sample(random: RANDOM),

    country: country,
    status: status,
    joined_date: joined_date,

    created_at: Time.current,
    updated_at: Time.current
  }

  if employee_rows.size >= BATCH_SIZE
    Employee.insert_all(employee_rows)
    employee_rows.clear

    puts "  Employees: #{employee_code}/#{EMPLOYEE_COUNT}"
  end
end

Employee.insert_all(employee_rows) if employee_rows.any?

puts "Employees created: #{Employee.count}"

# ------------------------------------------------------------
# Current salary structures
# ------------------------------------------------------------

puts "Creating current salary structures..."

salary_rows = []

Employee.order(:employee_code).find_each do |employee|
  country_config = COUNTRIES.fetch(employee.country)

  base_salary = RANDOM.rand(
    country_config[:salary_range]
  )

  housing_allowance =
    (base_salary * RANDOM.rand(0.05..0.15)).round(2)

  conveyance_allowance =
    (base_salary * RANDOM.rand(0.02..0.05)).round(2)

  special_allowance =
    (base_salary * RANDOM.rand(0.03..0.10)).round(2)

  salary_rows << {
    employee_id: employee.id,

    effective_from: Date.new(2026, 1, 1),
    effective_to: nil,

    currency: country_config[:currency],

    base_salary: base_salary,
    housing_allowance: housing_allowance,
    conveyance_allowance: conveyance_allowance,
    special_allowance: special_allowance,

    created_at: Time.current,
    updated_at: Time.current
  }

  if salary_rows.size >= BATCH_SIZE
    SalaryStructure.insert_all(salary_rows)
    salary_rows.clear
  end
end

SalaryStructure.insert_all(salary_rows) if salary_rows.any?

puts "Current salary structures: #{SalaryStructure.count}"

# ------------------------------------------------------------
# Salary history
# ------------------------------------------------------------

puts "Creating salary history..."

history_rows = []

Employee
  .order(:employee_code)
  .each_with_index do |employee, index|

  # Approximately 30% of employees have historical compensation.
  next unless index % 3 == 0

  current_salary = SalaryStructure
    .where(employee_id: employee.id)
    .order(effective_from: :desc)
    .first

  next unless current_salary

  [
    [Date.new(2024, 1, 1), 0.85],
    [Date.new(2025, 1, 1), 0.92]
  ].each do |effective_from, multiplier|

    history_rows << {
      employee_id: employee.id,

      effective_from: effective_from,
      effective_to: effective_from.next_year - 1.day,

      currency: current_salary.currency,

      base_salary: (
        current_salary.base_salary * multiplier
      ).round(2),

      housing_allowance: (
        current_salary.housing_allowance * multiplier
      ).round(2),

      conveyance_allowance: (
        current_salary.conveyance_allowance * multiplier
      ).round(2),

      special_allowance: (
        current_salary.special_allowance * multiplier
      ).round(2),

      created_at: Time.current,
      updated_at: Time.current
    }

    if history_rows.size >= BATCH_SIZE
      SalaryStructure.insert_all(history_rows)
      history_rows.clear
    end
  end
end

SalaryStructure.insert_all(history_rows) if history_rows.any?

# ------------------------------------------------------------
# Summary
# ------------------------------------------------------------

puts
puts "============================================"
puts "Seed completed"
puts "============================================"

puts "Employees: #{Employee.count}"
puts "Departments: #{Department.count}"
puts "Salary structures: #{SalaryStructure.count}"

puts "Active employees: #{Employee.where(status: "active").count}"
puts "Terminated employees: #{Employee.where(status: "terminated").count}"
puts "Employees on leave: #{Employee.where(status: "on_leave").count}"

puts "Countries: #{Employee.distinct.count(:country)}"

puts "Currencies: #{SalaryStructure.distinct.pluck(:currency).sort.join(", ")}"

puts
puts "Employees by department:"

Employee
  .joins(:department)
  .group("departments.name")
  .count
  .sort
  .each do |department, count|

  puts "  #{department}: #{count}"
end

puts
puts "Salary structures by currency:"

SalaryStructure
  .group(:currency)
  .count
  .sort
  .each do |currency, count|

  puts "  #{currency}: #{count}"
end

puts
puts "HR login:"
puts "  Email: hr@example.com"
puts "  Password: Password123!"