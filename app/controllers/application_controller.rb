class ApplicationController < ActionController::API
    include Pagy::Method
    include Authenticatable
end
