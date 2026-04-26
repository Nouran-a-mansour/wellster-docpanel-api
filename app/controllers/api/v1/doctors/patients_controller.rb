module Api
  module V1
    module Doctors
      class PatientsController < BaseController
        before_action :set_doctor

        VALID_SORT_OPTIONS = %w[last_name closest_appointment].freeze

        def index
          patients = @doctor.patients.includes(:indication, :appointments)
          patients = apply_sort(patients)

          render json: serialize_patients(patients), status: :ok
        end

        def create
          patient = Patient.find(patient_params[:patient_id])

          if patient.doctor_id.present?
            return render json: { error: I18n.t("api.errors.patient_already_assigned") },
                          status: :unprocessable_content
          end

          unless @doctor.indication_ids.include?(patient.indication_id)
            return render json: { error: I18n.t("api.errors.doctor_not_qualified") },
                          status: :unprocessable_content
          end

          patient.update!(doctor: @doctor)

          render json: serialize_patient(patient), status: :created
        end

        private

        def set_doctor
          @doctor = Doctor.find(params[:doctor_id])
        end

        def patient_params
          params.require(:patient).permit(:patient_id)
        end

        def apply_sort(patients)
          sort = params[:sort]

          return patients.sorted_by_last_name unless VALID_SORT_OPTIONS.include?(sort)

          sort == "closest_appointment" ? patients.sorted_by_closest_appointment : patients.sorted_by_last_name
        end

        def serialize_patients(patients)
          patients.map { |p| serialize_patient(p) }
        end

        def serialize_patient(patient)
          {
            id: patient.id,
            first_name: patient.first_name,
            last_name: patient.last_name,
            email: patient.email,
            indication: {
              id: patient.indication.id,
              name: patient.indication.name
            },
            next_appointment: patient.appointments
                                     .where("scheduled_at > ?", Time.current)
                                     .order(:scheduled_at)
                                     .first
                                     &.scheduled_at
          }
        end
      end
    end
  end
end
