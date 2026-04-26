module Api
  module V1
    module Doctors
      class AvailablePatientsController < BaseController
        before_action :set_doctor

        def index
          patients = @doctor.available_patients.includes(:indication)

          render json: serialize_patients(patients), status: :ok
        end

        private

        def set_doctor
          @doctor = Doctor.find(params[:doctor_id])
        end

        def serialize_patients(patients)
          patients.map do |patient|
            {
              id: patient.id,
              first_name: patient.first_name,
              last_name: patient.last_name,
              email: patient.email,
              indication: {
                id: patient.indication.id,
                name: patient.indication.name
              }
            }
          end
        end
      end
    end
  end
end