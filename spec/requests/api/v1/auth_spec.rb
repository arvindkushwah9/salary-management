require "swagger_helper"

RSpec.describe "Authentication API", type: :request do
  path "/api/v1/auth/login" do
    post "Login" do
      tags "Authentication"
      consumes "application/json"
      produces "application/json"

      parameter name: :credentials,
                in: :body,
                required: true,
                schema: {
                  type: :object,
                  required: %w[email password],
                  properties: {
                    email: { type: :string, format: :email },
                    password: { type: :string }
                  }
                }

      response "200", "login successful" do
        let!(:user) do
          create(
            :user,
            email: "hr@example.com",
            password: "Password123!",
            role: "hr_manager"
          )
        end

        let(:credentials) do
          {
            email: "hr@example.com",
            password: "Password123!"
          }
        end

        run_test! do |response|
          body = JSON.parse(response.body)

          expect(body["data"]["token"]).to be_present
          expect(body["data"]["user"]).to include(
            "id" => user.id,
            "email" => "hr@example.com",
            "role" => "hr_manager"
          )
        end
      end

      response "401", "invalid credentials" do
        let!(:user) do
          create(
            :user,
            email: "hr@example.com",
            password: "Password123!",
            role: "hr_manager"
          )
        end

        let(:credentials) do
          {
            email: "hr@example.com",
            password: "WrongPassword!"
          }
        end

        run_test!
      end
    end
  end
end