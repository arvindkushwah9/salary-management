# Performance Considerations

## 1. Target Dataset

The assessment specifies approximately 10,000 employees.

The implementation is designed so that the employee directory does not require loading all employees into the browser.

## 2. Employee Directory

The employee list uses server-side:

- Pagination
- Search
- Status filtering
- Country filtering
- Department filtering
- Salary availability filtering

This keeps browser payloads bounded by the requested page size.

## 3. Database Indexing

Indexes are used on important relationship and lookup columns.

Relevant areas include:

- Employee department
- Salary structure employee
- Salary effective dates
- Payroll period
- Payroll status
- Payroll currency

Indexes should be reviewed against real production query plans if the dataset grows substantially.

## 4. Payroll Iteration

Payroll processing uses ActiveRecord batch iteration:

```ruby
Employee.active.find_each do |employee|
  # process employee
end
````

This avoids loading the complete active employee relation into memory at once.

## 5. Database Aggregation

Payroll totals use database aggregation for gross, deductions, and net rather than retrieving all amounts and summing the values entirely in Ruby.

Examples include:

```text
SUM(gross_earnings)
SUM(total_deductions)
SUM(net_pay)
```

## 6. Transactional Consistency

Payroll processing runs inside a database transaction.

Payslip item changes also recalculate payslip and payroll totals transactionally.

This favors correctness over maximum throughput for the assessment implementation.

## 7. Current Payroll Processing Characteristics

The current payroll service creates payslips synchronously.

For approximately 10,000 employees, this is suitable as an assessment implementation but would eventually become a candidate for background processing.

## 8. Potential Scaling Improvements

If payroll volumes become substantially larger, possible improvements include:

### Background Jobs

Move payroll processing to a background job.

```text
HTTP Request
     ↓
Create Payroll Job
     ↓
Queue
     ↓
Payroll Worker
     ↓
Process in batches
```

### Progress Tracking

Store payroll processing progress:

```text
processed employees
total employees
failed employees
current state
```

### Batch Writes

Where appropriate, reduce individual database writes through batch operations.

### Caching

Dashboard aggregates that do not need real-time recalculation could be cached.

### Query Optimization

Use PostgreSQL `EXPLAIN ANALYZE` against real production-like datasets to validate indexes and query plans.

## 9. Frontend Performance

The frontend uses:

* Server-side pagination through the API
* Bounded table rendering
* Reusable loading states
* Direct file downloads
* URL-driven filtering

It avoids rendering thousands of employee rows simultaneously.

## 10. Performance Testing

A production implementation should add benchmark/load testing around:

* Employee search
* Employee filtering
* Dashboard aggregation
* Payroll processing
* Payslip generation
* Export generation

The assessment implementation documents the scaling strategy without introducing infrastructure complexity that was not required.

```