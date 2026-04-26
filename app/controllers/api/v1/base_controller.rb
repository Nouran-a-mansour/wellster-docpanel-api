module Api
  module V1
    class BaseController < ApplicationController
      rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
      rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_content

      private

      def record_not_found(exception)
        render json: { error: exception.message }, status: :not_found
      end

      def unprocessable_content(exception)
        render json: { error: exception.message }, status: :unprocessable_content
      end
    end
  end
end