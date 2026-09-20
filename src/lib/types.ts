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