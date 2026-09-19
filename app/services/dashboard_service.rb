class DashboardService
  def initialize
    @employees = Employee.all
    @salary_structures = SalaryStructure.all
  end

  def call
    {
      employees: employee_summary,
      countries: country_summary,
      salary: salary_summary
    }
  end

  private

  def employee_summary
    {
      total: @employees.count,
      active: @employees.active.count,
      inactive: @employees.inactive.count
    }
  end

  def country_summary
    {
      count: @employees.distinct.count(:country),
      employee_count_by_country: @employees
        .group(:country)
        .order(:country)
        .count
    }
  end

  def salary_summary
    {
      employees_with_salary: @salary_structures
        .distinct
        .count(:employee_id),
      currencies: @salary_structures
        .distinct
        .order(:currency)
        .pluck(:currency),
      statistics_by_currency: salary_statistics_by_currency
    }
  end

  def salary_statistics_by_currency
    @salary_structures
      .group(:currency)
      .pluck(
        :currency,
        Arel.sql("MIN(base_salary)"),
        Arel.sql("MAX(base_salary)"),
        Arel.sql("AVG(base_salary)")
      )
      .sort_by(&:first)
      .map do |currency, minimum, maximum, average|
        {
          currency: currency,
          minimum: minimum.to_f,
          maximum: maximum.to_f,
          average: average.to_f
        }
      end
  end
end