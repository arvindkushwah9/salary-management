# Salary Management System — Backend

Ruby on Rails API backend for the Salary Management System.

The application provides employee management, salary structures and history, salary insights, payroll runs, payslips, deductions, exports, authentication, API documentation, and reproducible seed data for approximately 10,000 employees.

## Tech Stack

- Ruby 3.3.3
- Ruby on Rails 8.1.3.1
- PostgreSQL
- UUID primary keys
- RSpec
- FactoryBot
- Rswag / OpenAPI
- Pagy
- JWT authentication
- bcrypt
- Prawn / Prawn Table
- caxlsx

## Features

### Authentication

- JWT-based authentication
- HR Manager role
- Protected API endpoints
- Password hashing with bcrypt
- Unauthorized requests return a consistent API error response

### Employee Management

- Create, view, update, and delete employees
- Search employees
- Filter by:
  - Status
  - Country
  - Department
  - Salary availability
- Paginated employee listing
- Department management
- Support for approximately 10,000 employees

### Salary Management

- Salary structures
- Multiple currencies
- Effective start/end dates
- Salary history
- Current salary lookup
- Base salary
- Housing allowance
- Conveyance allowance
- Special allowance
- Gross salary calculation
- Salary validation

### Dashboard / Salary Insights

The API supports salary and workforce statistics including:

- Total employees
- Active employees
- Inactive employees
- Employees with salary data
- Employee count by country
- Salary statistics by currency
- Minimum salary
- Maximum salary
- Average salary

Currency values are kept separate to avoid misleading comparisons between different currencies.

### Payroll

A lightweight payroll workflow is included as an extension of the core salary-management functionality.

Supported payroll states:

```text
draft
processing
approved
disbursed
```

Payroll processing includes:

- Payroll period and currency
- Active employee selection
- Current salary selection
- Payslip generation
- Earning items
- Deduction/statutory items
- Gross salary calculation
- Deduction calculation
- Net pay calculation
- Payroll total recalculation
- Payroll approval/disbursement workflow

Employees whose salary currency does not match the payroll run currency are excluded from that payroll run.

### Payslips

Payslips contain:

- Employee information
- Payroll run
- Currency
- Working days
- Paid days
- Gross earnings
- Total deductions
- Net pay
- Payment status
- Earning items
- Deduction/statutory items

Supported payment statuses:

```text
pending
paid
failed
```

### Deductions

HR can add explicit deduction or statutory items to a payslip.

When a deduction is added or removed:

1. Payslip deductions are recalculated.
2. Payslip net pay is recalculated.
3. Payroll totals are recalculated.

No country-specific tax rules are assumed or automatically calculated.

### Exports

Supported exports include:

#### Payroll CSV

```http
GET /api/v1/payroll_runs/:id/export?format=csv
```

#### Payroll Excel

```http
GET /api/v1/payroll_runs/:id/export?format=xlsx
```

#### Payslip PDF

```http
GET /api/v1/payslips/:id/export?format=pdf
```

## Project Structure

```text
app/
├── controllers/
│   └── api/
│       └── v1/
│           ├── auth_controller.rb
│           ├── departments_controller.rb
│           ├── employees_controller.rb
│           ├── payroll_runs_controller.rb
│           ├── payslips_controller.rb
│           └── payslip_items_controller.rb
│
├── models/
│   ├── user.rb
│   ├── department.rb
│   ├── employee.rb
│   ├── salary_structure.rb
│   ├── payroll_run.rb
│   ├── payslip.rb
│   └── payslip_item.rb
│
├── serializers/
│   ├── employee_serializer.rb
│   ├── salary_structure_serializer.rb
│   ├── payroll_run_serializer.rb
│   ├── payslip_serializer.rb
│   └── payslip_item_serializer.rb
│
└── services/
    └── payroll/
        └── process_service.rb

spec/
├── models/
├── requests/
├── services/
└── factories/

db/
├── migrate/
├── schema.rb
└── seeds.rb
```

## Setup

### Prerequisites

Install:

- Ruby 3.3.3
- Bundler
- PostgreSQL
- Git

Verify:

```bash
ruby -v
bundle -v
psql --version
```

Expected Ruby version:

```text
ruby 3.3.3
```

### Create the Rails Project

The application is built with Ruby on Rails 8.1.3.1.

If creating the project from scratch:

```bash
gem install rails -v 8.1.3.1
```

Verify Rails:

```bash
rails -v
```


> For normal setup, clone the completed repository instead. The repository already contains the application code, migrations, models, controllers, services, serializers, specs, factories, and seed implementation.

### Clone the Repository

```bash
git clone https://github.com/arvindkushwah9/salary-management-backend
cd salary-management-backend
```

Install dependencies:

```bash
bundle install
```

## PostgreSQL Setup

Make sure PostgreSQL is running.

On macOS with Homebrew:

```bash
brew services start postgresql
```

Check PostgreSQL:

```bash
psql --version
```

The application uses PostgreSQL for development and test environments.

Example development database:

```text
salary_management_backend_development
```

Example test database:

```text
salary_management_backend_test
```

If required, update:

```text
config/database.yml
```

Example:

```yml
development:
  <<: *default
  database: salary_management_backend_development

test:
  <<: *default
  database: salary_management_backend_test
```

## Install Dependencies

From the backend project directory:

```bash
bundle install
```

## Create Database

Create the development and test databases:

```bash
bin/rails db:create
```

Or individually:

```bash
RAILS_ENV=development bin/rails db:create
RAILS_ENV=test bin/rails db:create
```

## Run Migrations

Run all database migrations:

```bash
bin/rails db:migrate
```

Prepare the test database:

```bash
RAILS_ENV=test bin/rails db:migrate
```

Check migration status:

```bash
bin/rails db:migrate:status
```

## Seed the Database

The project includes a reproducible seed mechanism for approximately 10,000 employees.

The seed data includes:

- HR Manager account
- Departments
- Approximately 10,000 employees
- Multiple countries
- Multiple currencies
- Employee statuses
- Salary structures
- Salary history
- Representative payroll runs
- Payslips

Run the seed:

```bash
bin/rails db:seed
```

### Reset and Reseed

To completely recreate the development database:

```bash
bin/rails db:reset
```

Or explicitly:

```bash
bin/rails db:drop db:create db:migrate db:seed
```

> Warning: these commands delete the existing development database.

## Verify Seed Data

Open Rails console:

```bash
bin/rails console
```

Check employee count:

```ruby
Employee.count
```

Expected:

```text
10000
```

Check departments:

```ruby
Department.count
```

Check salary structures:

```ruby
SalaryStructure.count
```

Check payroll runs:

```ruby
PayrollRun.count
```

Check payslips:

```ruby
Payslip.count
```

Check the seeded HR account:

```ruby
User.find_by(email: "hr@example.com")
```

Exit:

```ruby
exit
```

## Default HR Manager Account

The seed creates a development HR Manager account:

```text
Email:    hr@example.com
Password: Password123!
```

These credentials are intended only for local/demo development and must not be used in production.

## Start the Rails API

Start the server on port `3001`:

```bash
bin/rails server -p 3001
```

Or:

```bash
bin/rails s -p 3001
```

The API will be available at:

```text
http://localhost:3001
```

## API Documentation

Swagger/OpenAPI documentation is available at:

```text
http://localhost:3001/api-docs
```

OpenAPI specification:

```text
http://localhost:3001/api-docs/v1/swagger.yaml
```

Regenerate the specification:

```bash
bundle exec rails rswag:specs:swaggerize
```

## Authentication

Login endpoint:

```http
POST /api/v1/auth/login
Content-Type: application/json
```

Example:

```json
{
  "email": "hr@example.com",
  "password": "Password123!"
}
```

The API returns a JWT token.

Use the token for protected endpoints:

```http
Authorization: Bearer <TOKEN>
```

## Testing

Run the complete test suite:

```bash
bundle exec rspec
```

Run model specs:

```bash
bundle exec rspec spec/models
```

Run request specs:

```bash
bundle exec rspec spec/requests
```

Run service specs:

```bash
bundle exec rspec spec/services
```

The test suite covers:

- Model validations
- Salary calculations
- Salary effective dates
- Employee filtering
- Authentication
- API authorization
- Employee API
- Salary API
- Payroll processing
- Payslip generation
- Payslip items
- Deduction calculations
- Payroll totals
- Export endpoints
- Invalid state handling
- Transaction rollback behavior

## Complete Fresh Setup

For a reviewer setting up the project from the repository:

```bash
git clone <BACKEND_REPOSITORY_URL>

cd salary-management-backend

bundle install

bin/rails db:create

bin/rails db:migrate

bin/rails db:seed

bundle exec rspec

bin/rails server -p 3001
```

Then open:

```text
http://localhost:3001/api-docs
```

The frontend can use:

```env
NEXT_PUBLIC_API_URL=http://localhost:3001/api/v1
```

## Payroll Processing Assumptions

The assessment does not define country-specific payroll rules.

Therefore:

- No tax engine is implemented.
- No country-specific statutory deductions are invented.
- Salary values are treated as payroll-period values.
- Explicit deduction/statutory items can be added by HR.
- Active employees are processed.
- Terminated and on-leave employees are skipped.
- Payroll currency must match the employee salary currency.
- Working days currently use calendar days because attendance/business-day rules were not provided.

These assumptions are intentional and documented rather than hidden in the implementation.

## API Error Format

Validation errors follow a consistent structure:

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Payslip item could not be saved",
    "details": {
      "amount": [
        "must be greater than or equal to 0"
      ]
    }
  }
}
```

Authentication errors:

```json
{
  "error": {
    "code": "UNAUTHORIZED",
    "message": "Authentication required"
  }
}
```

## Performance Considerations

The system is designed around the requirement of approximately 10,000 employees.

Important choices include:

- Database-level filtering
- Pagination
- Indexed foreign keys
- Indexed employee identifiers
- Indexed salary effective dates
- Batch seed creation
- `find_each` for payroll processing
- Database-level aggregation
- Avoiding loading the entire employee dataset into memory

Employee listing uses Pagy for pagination.

## Security Considerations

- Passwords are hashed using bcrypt.
- JWT authentication protects API endpoints.
- Employee and salary APIs require authentication.
- Strong parameters are used for writable attributes.
- Database foreign keys maintain referential integrity.
- Salary values are validated before persistence.
- Payroll state transitions are validated.
- No sensitive salary information is exposed through unauthenticated endpoints.

## Environment Variables

Typical development configuration:

```env
DATABASE_URL=postgresql://localhost/salary_management_backend_development
RAILS_ENV=development
```

Rails secret key infrastructure is used for JWT signing.

Do not commit production secrets or credentials.

## Development Commands

Start Rails:

```bash
bin/rails server -p 3001
```

Rails console:

```bash
bin/rails console
```

Run migrations:

```bash
bin/rails db:migrate
```

Reset database:

```bash
bin/rails db:reset
```

Seed database:

```bash
bin/rails db:seed
```

Run tests:

```bash
bundle exec rspec
```

Generate OpenAPI documentation:

```bash
bundle exec rails rswag:specs:swaggerize
```

## Troubleshooting

### PostgreSQL is not running

On macOS/Homebrew:

```bash
brew services start postgresql
```

Check:

```bash
brew services list
```

### Database does not exist

Run:

```bash
bin/rails db:create
```

### Migration issues

Check:

```bash
bin/rails db:migrate:status
```

For a disposable local database:

```bash
bin/rails db:reset
```

### Recreate seed data

Run:

```bash
bin/rails db:reset
```

### Port 3001 is already in use

Find the process:

```bash
lsof -i :3001
```

Or run Rails on another port:

```bash
bin/rails server -p 3002
```

Then update the frontend:

```env
NEXT_PUBLIC_API_URL=http://localhost:3002/api/v1
```

## Design Decisions

### Why Rails API?

Rails provides:

- Mature relational database support
- Strong validation mechanisms
- Clear domain modeling
- A mature testing ecosystem
- Fast development for CRUD and business workflows

### Why Service Objects?

Payroll processing contains business workflow logic that should not live inside controllers.

The main processing logic is isolated in:

```text
Payroll::ProcessService
```

This keeps controllers focused on HTTP concerns and makes payroll behavior easier to test.

### Why UUIDs?

UUID primary keys provide non-sequential identifiers and are suitable for distributed application architectures.

### Why Explicit Currency Handling?

Salary values from different countries cannot safely be aggregated without currency conversion.

The system therefore keeps currencies explicit and does not invent exchange rates.

## Out of Scope

The following are intentionally not implemented:

- Country-specific tax engines
- Banking/payment execution
- Benefits administration
- Attendance/timesheets
- Employee self-service
- Performance management
- Recruitment/ATS
- Complex organizational hierarchy
- Third-party payroll integrations
- Real-time notifications
- Mobile-native applications
- ML-based compensation recommendations

## Assessment Notes

This implementation intentionally favors:

- Clear domain boundaries
- Explicit assumptions
- Relational data modeling
- Testability
- API documentation
- Reproducible seed data
- Practical HR workflows
- Avoidance of unnecessary complexity

Where the requirements were ambiguous, the implementation documents an explicit assumption rather than silently introducing business rules.