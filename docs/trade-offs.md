# Engineering Trade-offs

## 1. Scope vs Complexity

The implementation intentionally focuses on the workflows required by the assessment instead of building a complete enterprise payroll platform.

This keeps the code understandable and allows business behavior to be tested directly.

Additional payroll features can be introduced once their business rules are defined.

## 2. JWT vs Server-Side Sessions

JWT authentication was selected because the frontend and backend are separate applications communicating through an API.

Advantages:

- Simple API authentication boundary.
- Stateless API requests.
- Easy separation between frontend and backend deployments.

Trade-offs:

- Token lifecycle and revocation require additional production considerations.
- Browser token storage requires appropriate security hardening.

For the assessment scope, JWT provides a straightforward authentication mechanism.

## 3. Service Object for Payroll

Payroll processing is implemented in:

```text
Payroll::ProcessService
````

Instead of placing the calculation logic inside the controller, the service owns the workflow.

This improves:

* Testability
* Separation of concerns
* Readability
* Reuse from non-HTTP entry points

## 4. Explicit Payslip Items

Payroll earnings and deductions are represented as individual payslip items.

This provides a flexible model for:

* Earnings
* Deductions
* Statutory items

It avoids hard-coding every future payroll component into the payslip table.

## 5. No Invented Tax Rules

No country-specific tax rules were supplied.

Implementing invented tax formulas would create business behavior that could be incorrect.

The implementation therefore starts with explicit deduction/statutory items.

A future tax engine can be added once requirements specify:

* Jurisdiction
* Tax year
* Tax brackets
* Exemptions
* Employee tax status
* Statutory contributions

## 6. Calendar Days for Working Days

The requirements did not define attendance or business-calendar rules.

Calendar days in the payroll month are therefore used as the initial working-day value.

This is explicit and deterministic rather than silently assuming a particular working-week model.

## 7. Currency Isolation Instead of Conversion

The application supports multiple currencies.

Payroll processing only combines salaries matching the payroll run currency.

Currency conversion was not introduced because no exchange-rate provider, rate date, rounding rule, or conversion policy was specified.

This prevents accidental financial calculations based on undocumented assumptions.

## 8. Server-Side Pagination

Approximately 10,000 employees are expected.

The frontend does not load all employees into the browser.

Filtering, searching, and pagination happen through the API/database.

This reduces:

* Browser memory usage
* Network payloads
* Rendering work
* Initial load time

## 9. UUID Primary Keys

UUIDs are used for primary keys.

Benefits include:

* Non-sequential public identifiers
* Easier separation of independently generated records
* Consistency across the domain model

The trade-off is larger indexes compared with integer keys.

For the assessment scale, the consistency and API-facing identifier characteristics were considered appropriate.

## 10. Database Transactions

Payroll operations and payslip item changes use transactions.

This prevents a partial update such as:

```text
Deduction created
but
Payslip total not updated
```

or:

```text
Payslip created
but
Payroll total update failed
```

The trade-off is that larger payroll operations can hold database transactions for longer.

For the assessment scope, correctness is prioritized.

## 11. Simple Status Model

Payroll status currently follows:

```text
draft
processing
approved
disbursed
```

A separate `processed` state was not introduced.

The current processing operation moves a draft payroll through processing and into approved state.

This keeps the state machine small while still supporting the required workflow.

## 12. Explicit Assumptions Instead of Hidden Behavior

Where requirements were ambiguous, the implementation documents assumptions.

Examples:

* Salary values are payroll-period values.
* Calendar days are used for working days.
* No automatic currency conversion.
* No country-specific tax calculations.
* Active employees are eligible for processing.
* Payroll currency must match salary currency.

This makes future requirement changes easier to identify.

```