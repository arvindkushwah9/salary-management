module Api
  module V1
    class AuthController < ApplicationController
      skip_before_action :authenticate_user!, only: :login

      def login
        user = User.find_by(email: params[:email].to_s.downcase.strip)

        unless user&.authenticate(params[:password])
          return render json: {
            error: {
              code: "INVALID_CREDENTIALS",
              message: "Invalid email or password"
            }
          }, status: :unauthorized
        end

        token = JsonWebToken.encode(user_id: user.id)

        render json: {
          data: {
            token: token,
            user: {
              id: user.id,
              email: user.email,
              role: user.role
            }
          }
        }
      end
    end
  end
end