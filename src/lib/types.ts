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