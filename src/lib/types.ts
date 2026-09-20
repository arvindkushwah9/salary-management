export type DashboardData = {
  employees: {
    total: number;
    active: number;
    inactive: number;
  };
  countries: {
    count: number;
    employee_count_by_country: Record<string, number>;
  };
  salary: {
    employees_with_salary: number;
    currencies: string[];
    statistics_by_currency: {
      currency: string;
      minimum: number;
      maximum: number;
      average: number;
    }[];
  };
};

export type Department = {
  id: string;
  code: string;
  name: string;
};

export type Employee = {
  id: string;
  employee_code: string;
  first_name: string;
  last_name: string;
  full_name: string;
  email: string;
  country: string;
  department: Department | null;
  job_title: string;
  status: "active" | "terminated" | "on_leave" | string;
  joined_date: string;
};

export type EmployeeListMeta = {
  page: number;
  per_page: number;
  total: number;
  pages: number;
};

export type EmployeeListResponse = {
  data: Employee[];
  meta: EmployeeListMeta;
};

export type EmployeeResponse = {
  data: Employee;
};

export type SalaryStructure = {
  id: string;
  employee_id: string;
  base_salary: number;
  housing_allowance: number;
  conveyance_allowance: number;
  special_allowance: number;
  gross_salary: number;
  currency: string;
  effective_from: string;
  effective_to: string | null;
};

export type SalaryStructureListResponse = {
  data: SalaryStructure[];
};

export type SalaryStructureResponse = {
  data: SalaryStructure;
};

export type DepartmentListResponse = {
  data: Department[];
};

export type PayrollRunStatus =
  | "draft"
  | "processing"
  | "approved"
  | "disbursed";

export type PayrollRun = {
  id: string;
  payroll_period: string;
  currency: string;
  status: PayrollRunStatus;
  total_gross: number;
  total_deductions: number;
  total_net: number;
  approved_by: string | null;
  approved_at: string | null;
  created_at: string;
  updated_at: string;
};

export type PayrollRunListResponse = {
  data: PayrollRun[];
};

export type PayrollRunResponse = {
  data: PayrollRun;
};

export type PayslipEmployee = {
  id: string;
  employee_code: string;
  full_name: string;
  email: string;
};

export type Payslip = {
  id: string;
  payroll_run_id: string;
  currency: string;
  employee_id: string;
  employee: PayslipEmployee;
  working_days: number;
  paid_days: number;
  gross_earnings: number;
  total_deductions: number;
  net_pay: number;
  payment_status: "pending" | "paid" | "failed" | string;
  payslip_pdf_url: string | null;
  created_at: string;
  updated_at: string;
};

export type PayslipListResponse = {
  data: Payslip[];
};

export type PayslipItemType =
  | "earning"
  | "deduction"
  | "statutory"
  | string;

export type PayslipItem = {
  id: string;
  payslip_id: string;
  item_type: PayslipItemType;
  code: string;
  description: string | null;
  amount: number;
  created_at: string;
  updated_at: string;
};

export type PayslipItemListResponse = {
  data: PayslipItem[];
};

export type PayslipResponse = {
  data: Payslip;
};