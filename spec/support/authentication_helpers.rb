module AuthenticationHelpers
  def auth_token
    user = create(
      :user,
      email: "test-hr@example.com",
      password: "Password123!",
      role: "hr_manager"
    )

    JsonWebToken.encode(user_id: user.id)
  end
end

RSpec.configure do |config|
  config.include AuthenticationHelpers, type: :request
end