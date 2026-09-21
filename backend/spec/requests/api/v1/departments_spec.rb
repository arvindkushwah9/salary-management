require "swagger_helper"

RSpec.describe "Departments API", type: :request do
  path "/api/v1/departments" do
    get "List departments" do
      tags "Departments"
      produces "application/json"

      security [bearerAuth: []]

      response "200", "departments found" do
        let(:user) { create(:user) }
        let(:token) { JsonWebToken.encode(user_id: user.id) }

        let(:Authorization) { "Bearer #{token}" }

        before do
          create(:department, code: "ENG", name: "Engineering")
          create(:department, code: "FIN", name: "Finance")
        end

        schema type: :object,
               properties: {
                 data: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id: { type: :string, format: :uuid },
                       code: { type: :string },
                       name: { type: :string }
                     },
                     required: %w[id code name]
                   }
                 }
               },
               required: ["data"]

        run_test!
      end
    end
  end
end