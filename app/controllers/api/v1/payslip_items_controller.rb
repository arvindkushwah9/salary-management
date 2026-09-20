module Api
  module V1
    class PayslipItemsController < ApplicationController
      before_action :set_payslip

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

        if payslip_item.save
          render json: {
            data: PayslipItemSerializer.new(payslip_item).as_json
          }, status: :created
        else
          render json: {
            error: {
              code: "VALIDATION_ERROR",
              message: "Payslip item could not be saved",
              details: payslip_item.errors.to_hash
            }
          }, status: :unprocessable_entity
        end
      end

      private

      def set_payslip
        @payslip = Payslip.find(params[:payslip_id])
      end

      def payslip_item_params
        params.require(:payslip_item).permit(
          :item_type,
          :code,
          :description,
          :amount
        )
      end
    end
  end
end