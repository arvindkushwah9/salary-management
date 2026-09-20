module Api
  module V1
    class PayslipsController < ApplicationController
      before_action :set_payroll_run, only: :index
      before_action :set_employee, only: :employee_index
      before_action :set_payslip, only: :show

      def index
        payslips = @payroll_run.payslips
                                .includes(:employee)
                                .order(created_at: :desc)

        render json: {
          data: payslips.map do |payslip|
            PayslipSerializer.new(payslip).as_json
          end
        }
      end

      def employee_index
        payslips = @employee.payslips
                            .includes(:payroll_run)
                            .order(created_at: :desc)

        render json: {
          data: payslips.map do |payslip|
            PayslipSerializer.new(payslip).as_json
          end
        }
      end

      def show
        render json: {
          data: PayslipSerializer.new(@payslip).as_json
        }
      end

      private

      def set_payroll_run
        @payroll_run = PayrollRun.find(params[:payroll_run_id])
      end

      def set_employee
        @employee = Employee.find(params[:id])
      end

      def set_payslip
        @payslip = Payslip.find(params[:id])
      end
    end
  end
end