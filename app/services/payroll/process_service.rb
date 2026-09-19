module Payroll
  class ProcessService
    def initialize(payroll_run)
      @payroll_run = payroll_run
    end

    def call
      PayrollRun.transaction do
        @payroll_run.update!(status: "processing")

        Employee.active.find_each do |employee|
          process_employee(employee)
        end

        update_totals!

        @payroll_run.update!(status: "approved")
      end

      @payroll_run
    end

    private

    def process_employee(employee)
      salary = employee.current_salary
      return unless salary

      payslip = @payroll_run.payslips.create!(
        employee: employee,
        working_days: 30,
        paid_days: 30,
        gross_earnings: salary.gross_salary,
        total_deductions: 0,
        net_pay: salary.gross_salary,
        payment_status: "pending"
      )

      create_earning_items(payslip, salary)
    end

    def create_earning_items(payslip, salary)
      create_item(
        payslip,
        "BASIC",
        "Base salary",
        salary.base_salary
      )

      create_item(
        payslip,
        "HRA",
        "Housing allowance",
        salary.housing_allowance
      )

      create_item(
        payslip,
        "CONVEYANCE",
        "Conveyance allowance",
        salary.conveyance_allowance
      )

      create_item(
        payslip,
        "SPECIAL",
        "Special allowance",
        salary.special_allowance
      )
    end

    def create_item(payslip, code, description, amount)
      payslip.payslip_items.create!(
        item_type: "earning",
        code: code,
        description: description,
        amount: amount
      )
    end

    def update_totals!
      @payroll_run.update!(
        total_gross: @payroll_run.payslips.sum(:gross_earnings),
        total_deductions: @payroll_run.payslips.sum(:total_deductions),
        total_net: @payroll_run.payslips.sum(:net_pay)
      )
    end
  end
end