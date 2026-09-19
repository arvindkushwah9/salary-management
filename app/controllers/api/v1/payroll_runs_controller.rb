module Api
  module V1
    class PayrollRunsController < ApplicationController
      before_action :set_payroll_run, only: %i[
        show
        update
        destroy
        process
        approve
      ]

      def index
        payroll_runs = PayrollRun.order(payroll_period: :desc)

        render json: {
          data: payroll_runs.map {
            |payroll_run|
            PayrollRunSerializer.new(payroll_run).as_json
          }
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
      end

      def process
        Payroll::ProcessService.new(@payroll_run).call

        render json: {
          data: PayrollRunSerializer.new(@payroll_run.reload).as_json
        }
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

      private

      def set_payroll_run
        @payroll_run = PayrollRun.find(params[:id])
      end

      def payroll_run_params
        params.require(:payroll_run).permit(
          :payroll_period,
          :status
        )
      end

      def render_validation_errors(record)
        render json: {
          error: {
            code: "VALIDATION_ERROR",
            message: "Payroll run could not be saved",
            details: record.errors.to_hash
          }
        }, status: :unprocessable_entity
      end
    end
  end
end