# db/seeds.rb

# Salary Management demo dataset.
#
# Creates:
# - 10,000 employees
# - 7 departments
# - Current salary for every employee
# - Salary history for approximately 30% of employees
# - Payroll runs
# - Payslips
# - Payslip items
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

NOW = Time.current

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

  # Also correct the name if the record already existed.
  department.update!(name: name) if department.name != name

  departments[name] = department
end

puts "  Departments: #{Department.count}"

# ------------------------------------------------------------
# HR user
# ------------------------------------------------------------

puts "Creating HR manager..."

hr_user = User.find_or_initialize_by(email: "hr@example.com")

hr_user.password = "Password123!" if hr_user.new_record?
hr_user.role = "hr_manager"

hr_user.save!

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

# Rebuild all demo transactional data.
#
# Delete children before parents because the application uses
# restrict_with_error associations and foreign keys.

if defined?(PayslipItem)
  PayslipItem.delete_all
end

if defined?(Payslip)
  Payslip.delete_all
end

if defined?(PayrollRun)
  PayrollRun.delete_all
end

if defined?(SalaryStructure)
  SalaryStructure.delete_all
end

Employee.delete_all

puts "  Existing employees and compensation data removed."

# ------------------------------------------------------------
# Employees
# ------------------------------------------------------------

puts "Creating #{EMPLOYEE_COUNT} employees..."

employee_rows = []

department_names = DEPARTMENT_DATA.map(&:last)
country_data = COUNTRIES.to_a

EMPLOYEE_COUNT.times do |index|
  employee_number = index + 1

  country, country_config = country_data.sample(
    random: RANDOM
  )

  department_name = department_names.sample(
    random: RANDOM
  )

  first_name = Faker::Name.first_name
  last_name = Faker::Name.last_name

  joined_date = Date.new(
    RANDOM.rand(2018..2025),
    RANDOM.rand(1..12),
    1
  )

  # Deterministic distribution:
  #
  # 5% active
  # 5% on leave
  # 90% terminated
  #
  # This keeps the dashboard populated with all statuses.

  status =
    case employee_number % 20
    when 0
      "active"
    when 1
      "on_leave"
    else
      "terminated"
    end

  designation = JOB_TITLES
    .fetch(department_name)
    .sample(random: RANDOM)

  employee_rows << {
    employee_code: "EMP-#{employee_number.to_s.rjust(5, "0")}",

    first_name: first_name,
    last_name: last_name,

    email: "employee#{employee_number}@example.com",

    department_id: departments.fetch(department_name).id,

    designation: designation,

    # Keep legacy column populated until it is removed.
    job_title: designation,

    country: country,

    status: status,

    joined_date: joined_date,

    created_at: NOW,
    updated_at: NOW
  }

  if employee_rows.size >= BATCH_SIZE
    Employee.insert_all(employee_rows)
    employee_rows.clear

    puts "  Employees: #{employee_number}/#{EMPLOYEE_COUNT}"
  end
end

Employee.insert_all(employee_rows) if employee_rows.any?

puts "Employees created: #{Employee.count}"

# ------------------------------------------------------------
# Current salary structures
# ------------------------------------------------------------

puts "Creating current salary structures..."

salary_rows = []

Employee
  .order(:employee_code)
  .find_each(batch_size: BATCH_SIZE) do |employee|

  country_config = COUNTRIES.fetch(employee.country)

  base_salary = RANDOM.rand(
    country_config[:salary_range]
  ).round(2)

  housing_allowance = (
    base_salary * RANDOM.rand(0.05..0.15)
  ).round(2)

  conveyance_allowance = (
    base_salary * RANDOM.rand(0.02..0.05)
  ).round(2)

  special_allowance = (
    base_salary * RANDOM.rand(0.03..0.10)
  ).round(2)

  salary_rows << {
    employee_id: employee.id,

    effective_from: Date.new(2026, 1, 1),
    effective_to: nil,

    currency: country_config[:currency],

    base_salary: base_salary,
    housing_allowance: housing_allowance,
    conveyance_allowance: conveyance_allowance,
    special_allowance: special_allowance,

    created_at: NOW,
    updated_at: NOW
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

  # Approximately 30% of employees have salary history.
  next unless index % 3 == 0

  current_salary = SalaryStructure
    .where(employee_id: employee.id)
    .where(effective_from: Date.new(2026, 1, 1))
    .order(effective_from: :desc)
    .first

  next unless current_salary

  [
    [Date.new(2024, 1, 1), Date.new(2024, 12, 31), 0.85],
    [Date.new(2025, 1, 1), Date.new(2025, 12, 31), 0.92]
  ].each do |effective_from, effective_to, multiplier|

    history_rows << {
      employee_id: employee.id,

      effective_from: effective_from,
      effective_to: effective_to,

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

      created_at: NOW,
      updated_at: NOW
    }

    if history_rows.size >= BATCH_SIZE
      SalaryStructure.insert_all(history_rows)
      history_rows.clear
    end
  end
end

SalaryStructure.insert_all(history_rows) if history_rows.any?

puts "Salary structures after history: #{SalaryStructure.count}"

# ------------------------------------------------------------
# Payroll demo data
# ------------------------------------------------------------

puts "Creating payroll demo data..."

# Create three payroll periods so the payroll UI has
# meaningful historical data.

PAYROLL_RUNS = [
  { period: "2026-07", currency: "USD" },
  { period: "2026-08", currency: "GBP" },
  { period: "2026-09", currency: "INR" }
].freeze

PAYROLL_RUNS.each do |config|
  payroll_run = PayrollRun.create!(
    payroll_period: config[:period],
    currency: config[:currency],
    status: "draft",
    total_gross: 0,
    total_deductions: 0,
    total_net: 0
  )

  Payroll::ProcessService.new(payroll_run).call

  payroll_run.update!(status: "disbursed") unless config[:period] == "2026-09"
end

puts "Payroll runs: #{PayrollRun.count}"

puts "Payslips: #{Payslip.count}"

puts "Payslip items: #{PayslipItem.count}"

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

puts "Payroll runs: #{PayrollRun.count}"

puts "Payslips: #{Payslip.count}"

puts "Payslip items: #{PayslipItem.count}"

puts
puts "Employee statuses:"

puts "  Active: #{Employee.where(status: "active").count}"

puts "  Terminated: #{Employee.where(status: "terminated").count}"

puts "  On leave: #{Employee.where(status: "on_leave").count}"

puts
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
puts "Payroll runs by status:"

PayrollRun
  .group(:status)
  .count
  .sort
  .each do |status, count|

  puts "  #{status}: #{count}"
end

puts
puts "HR login:"
puts "  Email: hr@example.com"
puts "  Password: Password123!"

puts
puts "============================================"