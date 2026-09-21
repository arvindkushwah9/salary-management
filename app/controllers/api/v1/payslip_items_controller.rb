module Api
  module V1
    class PayslipItemsController < ApplicationController
      before_action :set_payslip
      before_action :set_payslip_item, only: :destroy

      def index
        payslip_items = @payslip.payslip_items.order(created_at: :asc)

        render json: {
          data: payslip_items.map do |item|
            PayslipItemSerializer.new(item).as_json
          end
        }
      end

      def create
        payslip_item = @payslip.payslip_items.new(payslip_item_params)

        Payslip.transaction do
          unless payslip_item.save
            render_validation_errors(payslip_item)
            raise ActiveRecord::Rollback
          end

          @payslip.recalculate_totals!
          @payslip.payroll_run.recalculate_totals!
        end

        return if performed?

        render json: {
          data: PayslipItemSerializer.new(payslip_item).as_json
        }, status: :created
      end

      def destroy
        Payslip.transaction do
          @payslip_item.destroy!
          @payslip.recalculate_totals!
          @payslip.payroll_run.recalculate_totals!
        end

        head :no_content
      rescue ActiveRecord::RecordNotDestroyed => e
        render json: {
          error: {
            code: "DELETE_FAILED",
            message: e.record.errors.full_messages.to_sentence
          }
        }, status: :unprocessable_content
      end

      private

      def set_payslip
        @payslip = Payslip.find(params[:payslip_id])
      end

      def set_payslip_item
        @payslip_item = @payslip.payslip_items.find(params[:id])
      end

      def payslip_item_params
        params.require(:payslip_item).permit(
          :item_type,
          :code,
          :description,
          :amount
        )
      end

      def render_validation_errors(record)
        render json: {
          error: {
            code: "VALIDATION_ERROR",
            message: "Payslip item could not be saved",
            details: record.errors.to_hash
          }
        }, status: :unprocessable_content
      end
    end
  end
end