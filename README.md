# Salary Management System

A salary and payroll management application built as part of the Software Craftsperson/ROR - Staff engineering assessment.

The system provides an HR Manager workflow for managing employees, departments, salary structures, payroll runs, payslips, deductions, and exports.

## Project Overview

The application consists of:

- Rails API backend
- PostgreSQL database
- Next.js frontend
- JWT authentication
- Employee and department management
- Salary structures and salary history
- Workforce dashboard
- Multi-currency payroll
- Payslip generation
- Payslip deductions/statutory items
- CSV, Excel, and PDF exports
- Automated tests
- OpenAPI documentation

## Repository Structure

```text
salary-management/
│
├── backend/
│   ├── app/
│   ├── config/
│   ├── db/
│   ├── spec/
│   ├── Gemfile
│   └── README.md
│
├── frontend/
│   ├── app/
│   ├── src/
│   ├── public/
│   ├── package.json
│   └── README.md
│
└── docs/
    ├── requirements.md
    ├── architecture.md
    ├── trade-offs.md
    ├── performance.md
    └── ai-usage.md
````

## Documentation

The following documents explain the implementation and engineering decisions.

### Requirements

[Requirements Document](docs/requirements.md)

Covers:

* Problem statement
* Primary user
* Employee management
* Salary management
* Dashboard
* Payroll
* Payslips
* Deductions
* Exports
* Authentication
* Scale considerations
* Explicit assumptions
* Out-of-scope items
* Success criteria

### Architecture

[Architecture Document](docs/architecture.md)

Covers:

* Overall system architecture
* Backend architecture
* Frontend architecture
* Authentication flow
* Domain model
* Salary history
* Payroll processing
* Payslip calculations
* Currency handling
* API documentation
* Frontend data flow
* Transaction boundaries
* Future architecture extensions

### Engineering Trade-offs

[Trade-offs Document](docs/trade-offs.md)

Documents the reasoning behind key engineering decisions, including:

* Scope vs complexity
* JWT authentication
* Payroll service object
* Payslip item design
* Tax-rule handling
* Working-day calculation
* Currency isolation
* Server-side pagination
* UUIDs
* Database transactions
* Payroll status model
* Explicit assumptions

### Performance

[Performance Considerations](docs/performance.md)

Covers:

* Approximately 10,000 employees
* Server-side pagination
* Database filtering
* Database indexes
* Batch payroll processing
* Database aggregation
* Transactional consistency
* Frontend performance
* Potential future scaling improvements
* Performance testing considerations

### AI Usage

[AI Usage and Prompts](docs/ai-usage.md)

Documents:

* How AI tools were used during development
* Areas where AI assistance was used
* Representative prompts
* Human review process
* AI-assisted debugging examples
* Testing and verification
* Boundaries of AI usage

## Backend

The backend is a Ruby on Rails API.

### Technology

* Ruby 3.3.3
* Rails 8.1.3.1
* PostgreSQL
* UUID primary keys
* JWT authentication
* bcrypt
* RSpec
* Rswag/OpenAPI
* Pagy

See the backend README for complete setup instructions:

```text
backend/README.md
```

## Frontend

The frontend is a Next.js application for the HR Manager.

### Technology

* Next.js 16.3.5
* React 19.2.8
* TypeScript
* Tailwind CSS v4
* React Hook Form
* Zod
* Recharts
* Lucide React

See the frontend README for complete setup instructions:

```text
frontend/README.md
```

## Core Features

### Authentication

* HR Manager login
* JWT authentication
* Protected API requests

### Employee Management

* Employee listing
* Search
* Pagination
* Country filtering
* Department filtering
* Status filtering
* Salary availability filtering
* Create employee
* Edit employee
* Employee details

### Salary Management

* Salary structures
* Salary history
* Effective dates
* Multiple currencies
* Base salary
* Housing allowance
* Conveyance allowance
* Special allowance
* Gross salary calculation

### Dashboard

* Total Employees
* Active Employees
* Inactive Employees
* Employees With Salary
* Country distribution
* Salary statistics
* Employee drill-down

### Payroll

* Create payroll run
* Payroll period
* Currency
* Process payroll
* Approve payroll
* Payroll totals
* Payslip listing

### Payslips

* Employee information
* Payroll information
* Earnings
* Deductions
* Statutory items
* Gross pay
* Net pay
* Working days
* Paid days
* Payment status

### Exports

* Payroll CSV
* Payroll Excel
* Payslip PDF

## Payroll Workflow

```text
Create Payroll Run
        |
        v
Select Period + Currency
        |
        v
Process Payroll
        |
        v
Generate Payslips
        |
        v
Review Payslips
        |
        v
Add / Review Deductions
        |
        v
Recalculate Totals
        |
        v
Approve Payroll
        |
        v
Export Results
```

## Development Setup

### Backend

```bash
cd backend

bundle install

bin/rails db:create
bin/rails db:migrate
bin/rails db:seed

bundle exec rspec

bin/rails server -p 3001
```

### Frontend

Open another terminal:

```bash
cd frontend

npm install
npm run dev
```

The frontend will normally be available at:

```text
http://localhost:3000
```

The backend API will normally be available at:

```text
http://localhost:3001
```

## Environment Configuration

Frontend:

```env
NEXT_PUBLIC_API_URL=http://localhost:3001/api/v1
```

The complete environment and deployment instructions are documented in the respective backend and frontend README files.

## Seed Data

The backend includes seed data designed to demonstrate the application at approximately 10,000 employees.

The seed data includes:

* Departments
* Employees
* Salary structures
* Salary history
* Multiple countries
* Multiple currencies
* HR Manager account
* Payroll demonstration data

Development login:

```text
Email:    hr@example.com
Password: Password123!
```

## Testing

### Backend

Run the complete RSpec suite:

```bash
cd backend
bundle exec rspec
```

### Frontend

Run linting:

```bash
cd frontend
npm run lint
```

Create a production build:

```bash
npm run build
```

## API Documentation

The backend uses Rswag/OpenAPI.

When the Rails application is running, Swagger UI is available at:

```text
http://localhost:3001/api-docs
```

## Design Principles

The implementation emphasizes:

* Simple and maintainable architecture
* Explicit business assumptions
* Separation of HTTP and business logic
* Transactional consistency
* Server-side pagination
* Currency-aware calculations
* Meaningful automated tests
* Reusable frontend components
* Clear API contracts
* Avoidance of unnecessary complexity

## Assessment Artifacts

The `docs/` directory contains the supporting artifacts requested for the assessment:

```text
docs/
├── requirements.md
├── architecture.md
├── trade-offs.md
├── performance.md
└── ai-usage.md
```

These documents provide additional context about the requirements, implementation approach, engineering decisions, performance strategy, and use of AI during development.

## Scope Boundaries

The implementation intentionally does not attempt to implement:

* Country-specific tax engines
* Attendance systems
* Leave management
* Benefits administration
* Banking/payment integrations
* Employee self-service
* Recruitment/ATS
* Performance management
* Mobile-native applications
* Advanced compensation recommendations

These areas would require additional business requirements before implementation.

## Future Improvements

Potential production enhancements include:

* Background payroll processing
* Payroll progress tracking
* Audit logging
* MFA
* More granular RBAC
* Country-specific tax engines
* Attendance and leave integrations
* Banking/payment integrations
* Payroll calculation workers
* Dashboard caching
* Additional performance/load testing

## Assessment Submission

This repository contains:

* Backend implementation
* Frontend implementation
* Automated tests
* Seed data
* API/OpenAPI documentation
* Requirements documentation
* Architecture documentation
* Engineering trade-offs
* Performance considerations
* AI usage documentation

The goal of the implementation is to demonstrate structured problem solving, maintainable engineering, meaningful tests, product thinking, and intentional technical decision-making rather than unnecessary system complexity.

```
