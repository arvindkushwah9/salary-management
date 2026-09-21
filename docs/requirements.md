# `docs/requirements.md`

# Salary Management System — Requirements

## 1. Problem Statement

Build a salary management application for an HR Manager to manage employees, departments, salary structures and history, workforce insights, payroll runs, payslips, deductions, and exports.

The solution consists of a Rails API backend, PostgreSQL database, and Next.js frontend.

## 2. Primary User

### HR Manager

The HR Manager can:

- Authenticate into the application.
- View workforce and salary insights.
- Create, view, update, and filter employees.
- Manage departments.
- Manage employee salary structures and salary history.
- Create and process payroll runs.
- Review payslips.
- Add explicit deduction/statutory items.
- Approve payroll.
- Export payroll and payslip data.

## 3. Employee Management

The system supports:

- Employee code
- First name
- Last name
- Email
- Department
- Designation
- Country
- Employment status
- Joined date

Supported stored employee statuses:

```text
active
on_leave
terminated
````

The employee directory supports:

* Search
* Status filtering
* Country filtering
* Department filtering
* Salary availability filtering
* Pagination

The `inactive` employee filter is derived and represents employees whose stored status is not `active`.

## 4. Salary Management

Each employee can have multiple salary structures over time.

A salary structure contains:

* Base salary
* Housing allowance
* Conveyance allowance
* Special allowance
* Currency
* Effective from
* Effective to

The system can determine the employee's current effective salary based on the effective date range.

Salary history is retained rather than overwritten.

## 5. Dashboard

The dashboard provides:

* Total employees
* Active employees
* Inactive employees
* Employees with salary
* Country distribution
* Salary statistics by currency
* Drill-down links to employee records

Dashboard drill-down examples include:

```text
/employees?status=active
/employees?status=inactive
/employees?has_salary=true
```

## 6. Payroll

A payroll run contains:

* Payroll period
* Currency
* Status
* Total gross
* Total deductions
* Total net
* Approval information

Supported payroll statuses:

```text
draft
processing
approved
disbursed
```

Payroll processing:

1. Validates that the payroll run is in draft state.
2. Changes the run to processing.
3. Finds eligible active employees.
4. Finds the current salary structure.
5. Requires salary currency to match payroll currency.
6. Creates a payslip.
7. Creates explicit earning items.
8. Calculates payroll totals.
9. Marks the run approved.

## 7. Payslips

A payslip contains:

* Employee
* Payroll run
* Currency
* Working days
* Paid days
* Gross earnings
* Total deductions
* Net pay
* Payment status

Supported payment statuses include:

```text
pending
paid
failed
```

## 8. Payslip Items and Deductions

Payslip items support:

```text
earning
deduction
statutory
```

Deductions and statutory items can be added explicitly to a payslip.

When a payslip item is created or deleted:

1. Payslip deduction totals are recalculated.
2. Payslip net pay is recalculated.
3. Payroll run totals are recalculated.

These operations are transactional.

## 9. Exports

The system supports:

* Payroll CSV
* Payroll Excel
* Payslip PDF

## 10. Authentication and API

The API uses JWT authentication.

Protected API requests use:

```http
Authorization: Bearer <TOKEN>
```

OpenAPI documentation is available through Rswag.

## 11. Scale and Performance

The employee dataset is designed around approximately 10,000 employees.

The employee directory uses:

* Server-side pagination
* Database-backed filtering
* Search
* Limited result pages

Payroll processing uses batch iteration rather than loading all active employees into memory at once.

## 12. Explicit Assumptions

### Salary Period

The requirements did not specify whether salary values are annual or monthly.

The implementation treats salary values as payroll-period amounts and does not silently perform annual-to-monthly conversion.

### Tax and Statutory Rules

Country-specific tax rules were not specified.

The initial implementation therefore does not invent country-specific tax calculations. Explicit deduction/statutory items can be added to payslips.

### Working Days

Attendance and business-calendar rules were not specified.

The current implementation uses calendar days in the payroll month as working days.

### Payroll Eligibility

Only active employees with a current salary structure matching the payroll run currency are processed.

Terminated and on-leave employees are skipped.

### Currency Conversion

Currency conversion is intentionally not performed because no exchange-rate source or conversion policy was specified.

### Payroll State

The current processing flow is:

```text
draft → processing → approved
```

A payroll run can subsequently be marked disbursed.

## 13. Out of Scope

The implementation does not attempt to provide:

* Country-specific tax engines
* Attendance integration
* Leave calculations
* Benefits administration
* Banking/payment integration
* Employee self-service
* Recruitment/ATS
* Performance management
* Mobile-native applications
* Advanced compensation recommendations

These can be added when corresponding business requirements are defined.

## 14. Success Criteria

The solution should provide:

* A usable HR Manager workflow.
* Correct employee and salary management.
* Historical salary structures.
* Currency-aware payroll processing.
* Payslip generation and review.
* Explicit deduction handling.
* Meaningful automated tests.
* API documentation.
* Export functionality.
* Seed data suitable for demonstrating the application at approximately 10,000 employees.
* Clear documentation of assumptions and engineering decisions.

```