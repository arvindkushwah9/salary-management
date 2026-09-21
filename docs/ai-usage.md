
# AI Usage

## 1. Overview

AI tools were used as an engineering assistant during development.

The purpose was to accelerate exploration, debugging, code review, testing, documentation, and edge-case discovery while keeping engineering decisions under human review.

AI-generated suggestions were treated as recommendations rather than authoritative implementation decisions.

## 2. Areas Where AI Was Used

AI assistance was used for:

- Exploring Rails architecture options
- Reviewing model relationships
- Reviewing API design
- Debugging Rails and PostgreSQL errors
- Identifying edge cases
- Improving test coverage
- Reviewing frontend/backend type consistency
- Reviewing API contracts
- Generating documentation drafts
- Reviewing performance considerations
- Reviewing error handling
- Refining UI implementation
- Reviewing maintainability

## 3. Example Prompts

### Requirements Analysis

```text
Review the salary management requirements and identify the core domain
entities, workflows, ambiguities, and assumptions that should be clarified
before implementation. Do not invent business rules where the requirements
are unspecified.
````

### Rails Architecture

```text
Review this salary management Rails API architecture. Suggest a simple,
maintainable structure for employees, departments, salary history, payroll
runs, payslips, and payslip items. Avoid unnecessary enterprise complexity.
```

### Payroll Service Review

```text
Review this payroll processing service for correctness. Check employee
eligibility, current salary selection, effective dates, currency mismatches,
duplicate processing, transactions, totals, and rollback behavior.

Identify meaningful edge cases and corresponding tests.
```

### Testing

```text
Review the payroll service and suggest meaningful RSpec examples that test
business behavior rather than implementation details.

Include successful processing, invalid state, missing salary, expired salary,
future salary, employee status, currency mismatch, totals, and transaction
rollback.
```

### Performance

```text
Review this employee listing implementation for a dataset of approximately
10,000 employees.

Identify N+1 queries, unnecessary data loading, pagination/filtering issues,
and opportunities for database-backed optimization.
```

### API Contract

```text
Review the Rails API response structure and corresponding TypeScript types.

Identify naming mismatches, missing fields, nullable fields, and incorrect
status unions between the backend and frontend.
```

### Frontend Review

```text
Review this Next.js HR management screen for maintainability, loading states,
empty states, API errors, form validation, responsive behavior,
accessibility, and unnecessary client-side work.
```

### Code Review

```text
Review this implementation as a Staff-level Ruby on Rails engineer.

Identify correctness, maintainability, testing, architecture, and performance
concerns.

Do not recommend additional complexity unless it is justified by the
requirements.
```

## 4. Human Review Process

AI suggestions were reviewed against:

* Assessment requirements
* Existing application behavior
* Database constraints
* Automated tests
* API behavior
* Manual UI testing
* Explicitly documented assumptions

AI-generated suggestions were adapted where necessary to match the actual implementation and requirements.

## 5. Examples of AI-Assisted Debugging

AI-assisted debugging helped investigate and resolve issues including:

* Rails controller method collision with `process`
* PostgreSQL index rename behavior during migrations
* Payroll uniqueness constraints involving currency
* Current salary selection for expired and future salary structures
* Payslip deduction total recalculation
* Frontend TypeScript status-filter unions
* Next.js `useSearchParams` Suspense requirements
* Frontend/backend field naming consistency
* Rswag authentication and OpenAPI setup
* Export dependency and configuration issues

## 6. Testing and Verification

AI suggestions were not accepted without verification.

Implementation changes were validated using:

* RSpec
* Rails request specs
* Next.js TypeScript compilation
* Next.js production builds
* ESLint
* API responses
* Database behavior
* Manual UI testing

## 7. AI Boundaries

AI was not used as a substitute for:

* Running tests
* Inspecting actual error output
* Verifying database behavior
* Checking API responses
* Manual UI verification
* Making undocumented payroll business rules
* Making final architectural decisions

The final implementation and engineering decisions remained based on the assessment requirements, observed application behavior, and explicit assumptions documented in this repository.

```