module Api
  module V1
    class DashboardController < ApplicationController
      def show
        render json: {
          data: DashboardService.new.call
        }
      end
    end
  end
end