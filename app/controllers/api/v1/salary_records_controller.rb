module Api
  module V1
    class SalaryRecordsController < ApplicationController
      before_action :set_employee
      before_action :set_salary_record, only: %i[show update]

      def index
        salary_records = @employee.salary_records.latest_first

        render json: {
          data: salary_records.map do |salary_record|
            SalaryRecordSerializer.new(salary_record).as_json
          end
        }
      end

      def show
        render json: {
          data: SalaryRecordSerializer.new(@salary_record).as_json
        }
      end

      def create
        salary_record = @employee.salary_records.new(salary_record_params)

        if salary_record.save
          render json: {
            data: SalaryRecordSerializer.new(salary_record).as_json
          }, status: :created
        else
          render_validation_errors(salary_record)
        end
      end

      def update
        if @salary_record.update(salary_record_params)
          render json: {
            data: SalaryRecordSerializer.new(@salary_record).as_json
          }
        else
          render_validation_errors(@salary_record)
        end
      end

      private

      def set_employee
        @employee = Employee.find(params[:employee_id])
      end

      def set_salary_record
        @salary_record = @employee.salary_records.find(params[:id])
      end

      def salary_record_params
        params.require(:salary_record).permit(
          :amount,
          :currency,
          :effective_date
        )
      end

      def render_validation_errors(salary_record)
        render json: {
          error: {
            code: "VALIDATION_ERROR",
            message: "Salary record could not be saved",
            details: salary_record.errors.to_hash
          }
        }, status: :unprocessable_entity
      end
    end
  end
end