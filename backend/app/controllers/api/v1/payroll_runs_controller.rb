module Api
  module V1
    class PayrollRunsController < ApplicationController
      before_action :set_payroll_run,
                    only: %i[show update destroy process_payroll approve]

      def index
        payroll_runs = PayrollRun.order(payroll_period: :desc)

        render json: {
          data: payroll_runs.map do |payroll_run|
            PayrollRunSerializer.new(payroll_run).as_json
          end
        }
      end

      def show
        render json: {
          data: PayrollRunSerializer.new(@payroll_run).as_json
        }
      end

      def create
        payroll_run = PayrollRun.new(payroll_run_params)

        if payroll_run.save
          render json: {
            data: PayrollRunSerializer.new(payroll_run).as_json
          }, status: :created
        else
          render_validation_errors(payroll_run)
        end
      end

      def update
        if @payroll_run.update(payroll_run_params)
          render json: {
            data: PayrollRunSerializer.new(@payroll_run).as_json
          }
        else
          render_validation_errors(@payroll_run)
        end
      end

      def destroy
        @payroll_run.destroy!

        head :no_content
      rescue ActiveRecord::DeleteRestrictionError
        render json: {
          error: {
            code: "PAYROLL_RUN_IN_USE",
            message: "Payroll run cannot be deleted because it has payslips."
          }
        }, status: :unprocessable_content
      end

      def process_payroll
        Payroll::ProcessService.new(@payroll_run).call

        render json: {
          data: PayrollRunSerializer.new(@payroll_run.reload).as_json
        }
      rescue ArgumentError => e
        render json: {
          error: {
            code: "INVALID_PAYROLL_STATE",
            message: e.message
          }
        }, status: :unprocessable_content
      end

      def approve
        @payroll_run.update!(
          status: "approved",
          approved_by: current_user.id,
          approved_at: Time.current
        )

        render json: {
          data: PayrollRunSerializer.new(@payroll_run).as_json
        }
      end

      def export
        payroll_run = PayrollRun
          .includes(payslips: :employee)
          .find(params[:id])

        case params[:format]
        when "csv"
          export_csv(payroll_run)
        when "xlsx"
          export_excel(payroll_run)
        else
          render json: {
            error: {
              code: "UNSUPPORTED_FORMAT",
              message: "Supported formats are csv and xlsx"
            }
          }, status: :bad_request
        end
      end

      private

      def set_payroll_run
        @payroll_run = PayrollRun.find(params[:id])
      end

      def payroll_run_params
        params.require(:payroll_run).permit(
          :payroll_period,
          :currency
        )
      end

      def render_validation_errors(payroll_run)
        render json: {
          error: {
            code: "VALIDATION_ERROR",
            message: "Payroll run could not be saved",
            details: payroll_run.errors.to_hash
          }
        }, status: :unprocessable_content
      end

      def export_csv(payroll_run)
        require "csv"
        csv = CSV.generate(headers: true) do |csv|
          csv << [
            "Employee Code",
            "Employee Name",
            "Email",
            "Working Days",
            "Paid Days",
            "Gross Earnings",
            "Deductions",
            "Net Pay",
            "Payment Status"
          ]

          payroll_run.payslips.each do |payslip|
            csv << [
              payslip.employee.employee_code,
              payslip.employee.full_name,
              payslip.employee.email,
              payslip.working_days,
              payslip.paid_days,
              payslip.gross_earnings,
              payslip.total_deductions,
              payslip.net_pay,
              payslip.payment_status
            ]
          end
        end

        send_data csv,
                  filename: "payroll-#{payroll_run.payroll_period}-#{payroll_run.currency}.csv",
                  type: "text/csv",
                  disposition: "attachment"
      end

      def export_excel(payroll_run)
        require "axlsx"

        package = Axlsx::Package.new

        package.workbook.add_worksheet(
          name: "Payroll #{payroll_run.payroll_period}"
        ) do |sheet|

          header_style = sheet.workbook.styles.add_style(b: true)

          sheet.add_row [
            "Employee Code",
            "Employee Name",
            "Email",
            "Working Days",
            "Paid Days",
            "Gross Earnings",
            "Deductions",
            "Net Pay",
            "Payment Status"
          ], style: header_style

          payroll_run.payslips.each do |payslip|
            sheet.add_row [
              payslip.employee.employee_code,
              payslip.employee.full_name,
              payslip.employee.email,
              payslip.working_days,
              payslip.paid_days,
              payslip.gross_earnings.to_f,
              payslip.total_deductions.to_f,
              payslip.net_pay.to_f,
              payslip.payment_status
            ]
          end
        end

        send_data package.to_stream.read,
                  filename: "payroll-#{payroll_run.payroll_period}-#{payroll_run.currency}.xlsx",
                  type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
                  disposition: "attachment"
      end
    end
  end
end