# Salary Management System — Frontend

Next.js frontend for the Salary Management System.

The application provides an HR Manager interface for employee management, salary structures and history, workforce insights, payroll runs, payslips, deductions, and exports.

## Tech Stack

- Next.js 16.3.5
- React 19.2.8
- TypeScript
- Tailwind CSS v4
- TanStack React Query
- React Hook Form
- Zod
- Recharts
- Lucide React

## Features

### Authentication

- HR Manager login
- JWT authentication
- Protected application screens
- Authentication token used for API requests
- Automatic redirect to login for unauthenticated users

### Dashboard

The dashboard provides HR-focused workforce and salary metrics including:

- Total Employees
- Active Employees
- Inactive Employees
- Employees With Salary
- Country distribution
- Salary statistics
- Salary insights
- Drill-down links to employee records

Dashboard cards can navigate directly to filtered employee views.

Examples:

```text
Active Employees
    ↓
/employees?status=active
```

```text
Inactive Employees
    ↓
/employees?status=inactive
```

```text
Employees With Salary
    ↓
/employees?has_salary=true
```

### Employee Management

The employee directory supports:

- Employee search
- Status filtering
- Country filtering
- Department filtering
- Salary availability filtering
- Pagination
- Employee details
- Create employee
- Edit employee
- Salary history
- Add salary structure

Supported employee statuses:

```text
active
on_leave
terminated
```

`inactive` is a derived filter representing employees whose stored status is not `active`.

### Salary Management

The UI supports:

- Salary structures
- Salary history
- Effective dates
- Multiple currencies
- Base salary
- Housing allowance
- Conveyance allowance
- Special allowance
- Gross salary calculation

### Payroll

Payroll screens provide:

- Payroll run listing
- Create payroll run
- Payroll period
- Currency selection
- Process payroll
- Approve payroll
- Payroll totals
- Payslip listing
- Payroll exports

Supported payroll statuses:

```text
draft
processing
approved
disbursed
```

### Payslips

Payslip details display:

- Employee information
- Payroll information
- Currency
- Working days
- Paid days
- Gross earnings
- Deductions
- Net pay
- Earning items
- Deduction/statutory items
- Payment status

### Deductions

HR can add explicit deduction/statutory items to a payslip.

Supported item types:

```text
deduction
statutory
```

When a deduction is added or removed:

1. Payslip totals are recalculated.
2. Net pay is recalculated.
3. Payroll totals are recalculated.
4. Updated values are displayed in the UI.

### Exports

Supported exports:

- Payroll CSV
- Payroll Excel
- Payslip PDF

## Project Structure

```text
app/
├── page.tsx
├── login/
│   └── page.tsx
├── dashboard/
│   └── page.tsx
├── employees/
│   ├── page.tsx
│   ├── new/
│   │   └── page.tsx
│   └── [id]/
│       ├── page.tsx
│       ├── edit/
│       │   └── page.tsx
│       └── salary/
│           └── new/
│               └── page.tsx
├── payroll/
│   ├── page.tsx
│   ├── new/
│   │   └── page.tsx
│   └── [id]/
│       └── page.tsx
└── payslips/
    └── [id]/
        └── page.tsx

src/
├── components/
│   ├── dashboard/
│   ├── employees/
│   ├── salary/
│   ├── layout/
│   └── ui/
│
└── lib/
    ├── api.ts
    ├── auth.ts
    ├── formatters.ts
    └── types.ts
```

# Setup

## Prerequisites

Install:

- Node.js
- npm
- Git
- Running Salary Management Rails API

Verify:

```bash
node -v
npm -v
git --version
```

## Clone the Repository

```bash
git clone <FRONTEND_REPOSITORY_URL>
cd salary-management-frontend
```

## Install Dependencies

```bash
npm install
```

## Environment Configuration

Create a `.env.local` file in the project root:

```env
NEXT_PUBLIC_API_URL=http://localhost:3001/api/v1
```

The frontend uses `NEXT_PUBLIC_API_URL` as the backend API base URL.

Example production configuration:

```env
NEXT_PUBLIC_API_URL=https://api.example.com/api/v1
```

> Restart the Next.js development server after changing environment variables.

## Backend Setup

The frontend requires the Rails backend to be running.

From the backend project:

```bash
cd salary-management-backend
bundle install
bin/rails db:create
bin/rails db:migrate
bin/rails db:seed
bin/rails server -p 3001
```

The backend API will be available at:

```text
http://localhost:3001
```

The frontend API configuration should point to:

```text
http://localhost:3001/api/v1
```

## Start the Development Server

From the frontend project:

```bash
npm run dev
```

The application will normally be available at:

```text
http://localhost:3000
```

Open:

```text
http://localhost:3000/login
```

Use the seeded development HR Manager account:

```text
Email:    hr@example.com
Password: Password123!
```

## Complete Fresh Setup

For a reviewer setting up both applications locally:

### 1. Start Backend

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

### 2. Start Frontend

Open another terminal:

```bash
git clone <FRONTEND_REPOSITORY_URL>

cd salary-management-frontend

npm install
```

Create `.env.local`:

```env
NEXT_PUBLIC_API_URL=http://localhost:3001/api/v1
```

Start the frontend:

```bash
npm run dev
```

Open:

```text
http://localhost:3000
```

Login with:

```text
Email:    hr@example.com
Password: Password123!
```

## Production Build

Create an optimized production build:

```bash
npm run build
```

Start the production application:

```bash
npm run start
```

The application will normally be available at:

```text
http://localhost:3000
```

## Linting

Run ESLint:

```bash
npm run lint
```

## API Integration

The frontend uses a centralized API client:

```text
src/lib/api.ts
```

Authenticated requests automatically include:

```http
Authorization: Bearer <TOKEN>
```

The API base URL is configured using:

```env
NEXT_PUBLIC_API_URL
```

Example:

```env
NEXT_PUBLIC_API_URL=http://localhost:3001/api/v1
```

## Employee Filters

The employee directory supports URL-driven filters.

Examples:

```text
/employees?status=active
```

```text
/employees?status=inactive
```

```text
/employees?status=terminated
```

```text
/employees?has_salary=true
```

The dashboard uses these filters for drill-down navigation.

### Employee Status vs Status Filter

The actual employee status values are:

```text
active
on_leave
terminated
```

The employee list additionally supports:

```text
inactive
```

`inactive` is a derived filter representing employees whose stored status is not `active`.

## Currency Handling

Salary and payroll values are displayed with their currency.

Examples:

```text
USD 100,000.00
GBP 80,000.00
INR 500,000.00
```

The frontend does not perform currency conversion.

Different currencies are therefore not presented as directly comparable values.

## Payroll Workflow

Typical workflow:

```text
Payroll List
     ↓
Create Payroll Run
     ↓
Select Period + Currency
     ↓
Process Payroll
     ↓
Review Payslips
     ↓
Add/Review Deductions
     ↓
Approve Payroll
     ↓
Export Results
```

## Payslip Workflow

Typical workflow:

```text
Payroll Run
     ↓
Payslip
     ↓
Review Earnings
     ↓
Add Deduction / Statutory Item
     ↓
Totals Recalculated
     ↓
Net Pay Updated
     ↓
Download PDF
```

## Downloads

The frontend uses the authenticated download helper in:

```text
src/lib/api.ts
```

Supported downloads:

- Payroll CSV
- Payroll Excel
- Payslip PDF

Example:

```ts
await downloadFile(
  `/payslips/${payslip.id}/export?format=pdf`,
  `payslip-${payslip.id}.pdf`
);
```

## Loading and Error Handling

The UI provides reusable states for:

- Loading
- Empty results
- API errors
- Retry actions
- Success notifications
- Validation errors

Reusable UI components are located under:

```text
src/components/ui/
```

## Toast Notifications

A reusable toast notification system is available through:

```text
src/components/ui/Toast.tsx
src/components/ui/ToastProvider.tsx
```

Supported notification types:

```text
success
error
info
warning
```

Example:

```tsx
const { showToast } = useToast();

showToast("Payroll processed successfully", "success");
```

## Forms

Forms use:

- React Hook Form
- Zod where appropriate
- Client-side validation
- Backend/API validation
- User-friendly validation messages

Employee, salary, payroll, and deduction forms validate required fields before submitting data.

## Performance Considerations

The frontend is designed to work with approximately 10,000 employees.

The employee directory uses:

- Server-side pagination
- Server-side filtering
- Limited page sizes
- Search
- URL-driven filters
- Database-backed filtering through the Rails API

The frontend does not load all 10,000 employees into the browser.

## Responsive Design

The application uses Tailwind CSS with responsive layouts for:

- Desktop
- Tablet
- Smaller screens

Large tables use horizontal scrolling where necessary rather than forcing columns into an unreadable layout.

## Accessibility Considerations

The UI includes:

- Semantic buttons and links
- Form labels
- Accessible notification roles
- Keyboard-friendly controls
- Visible focus states
- Meaningful button labels
- Loading and error feedback

## Production Configuration

For production, configure:

```env
NEXT_PUBLIC_API_URL=https://<API_DOMAIN>/api/v1
```

Then create a production build:

```bash
npm run build
```

Start the production server:

```bash
npm run start
```

The backend must allow requests from the deployed frontend origin through its CORS configuration.

## Deployment

The frontend can be deployed to Vercel or another Node.js-compatible hosting platform.

Required environment variable:

```env
NEXT_PUBLIC_API_URL=<PRODUCTION_API_URL>
```

After changing environment variables, create a new production build.

## Development Commands

Start development server:

```bash
npm run dev
```

Build production application:

```bash
npm run build
```

Start production application:

```bash
npm run start
```

Run lint:

```bash
npm run lint
```

## Design Decisions

### Why Next.js?

Next.js provides:

- React-based UI
- File-system routing
- Production build tooling
- Client/server rendering options
- TypeScript support

### Why TypeScript?

TypeScript provides stronger contracts between:

- UI components
- API responses
- Forms
- Employee data
- Salary structures
- Payroll runs
- Payslips

This also helps detect mismatches between API and frontend terminology.

### Why a Centralized API Client?

API communication is centralized in:

```text
src/lib/api.ts
```

This provides a single place for:

- API base URL configuration
- Authentication headers
- JSON handling
- API errors
- File downloads

### Why URL-Based Employee Filters?

URL filters make dashboard drill-downs predictable and directly accessible.

For example:

```text
/employees?status=active
```

can be reached directly from the Active Employees dashboard card.

## Out of Scope

The frontend intentionally does not implement:

- Employee self-service
- Banking/payment interfaces
- Country-specific tax configuration
- Benefits administration
- Attendance/timesheets
- Performance management
- Recruitment/ATS
- Mobile-native applications
- Advanced ML compensation recommendations

## Assessment Notes

This implementation intentionally favors:

- Clear HR workflows
- Practical dashboard navigation
- Server-side pagination/filtering
- Explicit currency presentation
- Strong API typing
- Reusable UI components
- Meaningful error handling
- Simple and maintainable component structure
- Avoidance of unnecessary UI complexity

Where the requirements were ambiguous, the implementation documents an explicit assumption rather than silently introducing business rules.