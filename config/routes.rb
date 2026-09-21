Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  namespace :api do
    namespace :v1 do
      post "auth/login", to: "auth#login"

      resources :employees do
        resources :salary_structures, only: %i[index create show update]
        get :payslips, to: "payslips#employee_index", on: :member

      end

      get "dashboard", to: "dashboard#show"
      get "salary_reports", to: "salary_reports#index"

      resources :payroll_runs do
        member do
          post :process, action: :process_payroll
          post :approve
          get :export
        end

        resources :payslips, only: %i[index show]
      end

      resources :payslips, only: :show do
        member do
          get :export
        end
        resources :payslip_items, only: %i[index create destroy]
      end
      resources :departments, only: :index
    end
  end
end
