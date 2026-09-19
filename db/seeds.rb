# db/seeds.rb

# Deterministic salary-management demo dataset.
#
# Creates:
# - 10,000 employees
# - 1 current salary record per employee
# - salary history for a subset of employees
#
# Run with:
#   bin/rails db:seed

User.find_or_create_by!(email: "hr@example.com") do |user|
  user.password = "Password123!"
  user.role = "hr_manager"
end

require "faker"

EMPLOYEE_COUNT = 10_000
BATCH_SIZE = 1_000

COUNTRIES = {
  "US" => {
    currency: "USD",
    departments: %w[
      Engineering Product Sales Marketing Finance HR Operations
    ],
    salary_range: 70_000..180_000
  },
  "UK" => {
    currency: "GBP",
    departments: %w[
      Engineering Product Sales Marketing Finance HR Operations
    ],
    salary_range: 45_000..120_000
  },
  "IN" => {
    currency: "INR",
    departments: %w[
      Engineering Product Sales Marketing Finance HR Operations
    ],
    salary_range: 1_200_000..5_000_000
  },
  "DE" => {
    currency: "EUR",
    departments: %w[
      Engineering Product Sales Marketing Finance HR Operations
    ],
    salary_range: 50_000..130_000
  },
  "CA" => {
    currency: "CAD",
    departments: %w[
      Engineering Product Sales Marketing Finance HR Operations
    ],
    salary_range: 65_000..160_000
  },
  "AU" => {
    currency: "AUD",
    departments: %w[
      Engineering Product Sales Marketing Finance HR Operations
    ],
    salary_range: 75_000..180_000
  },
  "SG" => {
    currency: "SGD",
    departments: %w[
      Engineering Product Sales Marketing Finance HR Operations
    ],
    salary_range: 65_000..170_000
  },
  "NL" => {
    currency: "EUR",
    departments: %w[
      Engineering Product Sales Marketing Finance HR Operations
    ],
    salary_range: 50_000..125_000
  }
}.freeze

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
  "HR" => [
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

# Use a fixed Faker seed so the generated dataset is reproducible.
Faker::Config.random = Random.new(42)

puts "Starting salary management seed..."

# ------------------------------------------------------------
# Employees
# ------------------------------------------------------------

existing_employees = Employee.count

if existing_employees >= EMPLOYEE_COUNT
  puts "Employees already contain #{existing_employees} records. Skipping employee creation."
else
  employees_to_create = EMPLOYEE_COUNT - existing_employees

  puts "Creating #{employees_to_create} employees..."

  employees_to_create.times.each_slice(BATCH_SIZE).with_index do |batch, batch_index|
    rows = batch.map do |offset|
      employee_index = existing_employees + batch_index * BATCH_SIZE + offset + 1

      country, country_config = COUNTRIES.to_a.sample(
        random: Faker::Config.random
      )

      department = country_config[:departments].sample(
        random: Faker::Config.random
      )

      first_name = Faker::Name.first_name
      last_name = Faker::Name.last_name

      {
        employee_number: "EMP-#{employee_index.to_s.rjust(5, "0")}",
        first_name: first_name,
        last_name: last_name,
        email: "employee#{employee_index}@example.com",
        country: country,
        department: department,
        job_title: JOB_TITLES.fetch(department).sample(
          random: Faker::Config.random
        ),
        employment_status: employee_index % 20 == 0 ? "inactive" : "active",
        created_at: Time.current,
        updated_at: Time.current
      }
    end

    Employee.insert_all(rows)

    employees_created = [
      (batch_index + 1) * BATCH_SIZE,
      employees_to_create
    ].min

    puts "  Employees: #{employees_created}/#{employees_to_create}"
  end
end

# ------------------------------------------------------------
# Current salary records
# ------------------------------------------------------------

puts "Creating current salary records..."

employees_without_salary = Employee
  .left_joins(:salary_records)
  .where(salary_records: { id: nil })

puts "  Employees without salary: #{employees_without_salary.count}"

salary_rows = []

employees_without_salary.find_each do |employee|
  country_config = COUNTRIES.fetch(employee.country)

  amount = rand(
    country_config[:salary_range].begin..country_config[:salary_range].end
  )

  salary_rows << {
    employee_id: employee.id,
    amount: amount,
    currency: country_config[:currency],
    effective_date: Date.new(2026, 1, 1),
    created_at: Time.current,
    updated_at: Time.current
  }

  if salary_rows.size >= BATCH_SIZE
    SalaryRecord.insert_all(salary_rows)
    salary_rows.clear
  end
end

SalaryRecord.insert_all(salary_rows) if salary_rows.any?

# ------------------------------------------------------------
# Salary history
# ------------------------------------------------------------

puts "Creating salary history..."

history_rows = []

# Add two historical salary records for approximately 30% of employees.
Employee
  .joins(:salary_records)
  .distinct
  .order(:employee_number)
  .each_with_index do |employee, index|

  next unless index % 3 == 0

  current_salary = employee.current_salary
  next unless current_salary

  country_config = COUNTRIES.fetch(employee.country)

  [
    Date.new(2024, 1, 1),
    Date.new(2025, 1, 1)
  ].each_with_index do |effective_date, history_index|
    multiplier = history_index.zero? ? 0.85 : 0.92

    history_rows << {
      employee_id: employee.id,
      amount: (current_salary.amount * multiplier).round(2),
      currency: country_config[:currency],
      effective_date: effective_date,
      created_at: Time.current,
      updated_at: Time.current
    }

    if history_rows.size >= BATCH_SIZE
      SalaryRecord.insert_all(history_rows)
      history_rows.clear
    end
  end
end

SalaryRecord.insert_all(history_rows) if history_rows.any?

puts
puts "Seed completed."
puts "Employees: #{Employee.count}"
puts "Salary records: #{SalaryRecord.count}"
puts "Active employees: #{Employee.active.count}"
puts "Inactive employees: #{Employee.inactive.count}"
puts "Countries: #{Employee.distinct.count(:country)}"
puts "Currencies: #{SalaryRecord.distinct.pluck(:currency).sort.join(", ")}"