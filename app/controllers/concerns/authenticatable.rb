module Authenticatable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_user!
  end

  private

  def authenticate_user!
    token = request.headers["Authorization"]&.split(" ")&.last

    @current_user = User.find_by(
      id: JsonWebToken.decode(token)&.fetch("user_id", nil)
    )

    return if @current_user

    render json: {
      error: {
        code: "UNAUTHORIZED",
        message: "Authentication required"
      }
    }, status: :unauthorized
  end

  def current_user
    @current_user
  end
end