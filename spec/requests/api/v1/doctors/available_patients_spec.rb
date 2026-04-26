require 'rails_helper'

RSpec.describe "Api::V1::Doctors::AvailablePatients", type: :request do
  let(:diabetes)   { create(:indication, name: "Diabetes") }
  let(:hair_loss)  { create(:indication, name: "Hair Loss") }
  let(:doctor)     { create(:doctor, indications: [diabetes]) }

  describe "GET /api/v1/doctors/:doctor_id/available_patients" do
    context "when doctor exists" do
      let!(:unassigned_match)    { create(:patient, indication: diabetes) }
      let!(:unassigned_no_match) { create(:patient, indication: hair_loss) }
      let!(:assigned_match)      { create(:patient, indication: diabetes, doctor: doctor) }

      it "returns only unassigned patients with matching indication" do
        get "/api/v1/doctors/#{doctor.id}/available_patients"

        expect(response).to have_http_status(:ok)
        ids = JSON.parse(response.body).map { |p| p["id"] }
        expect(ids).to contain_exactly(unassigned_match.id)
      end

      it "does not include patients already assigned to any doctor" do
        other_doctor = create(:doctor, indications: [diabetes])
        assigned_to_other = create(:patient, indication: diabetes, doctor: other_doctor)

        get "/api/v1/doctors/#{doctor.id}/available_patients"

        ids = JSON.parse(response.body).map { |p| p["id"] }
        expect(ids).not_to include(assigned_to_other.id)
      end

      it "returns the correct patient attributes" do
        get "/api/v1/doctors/#{doctor.id}/available_patients"

        body = JSON.parse(response.body)
        patient_data = body.find { |p| p["id"] == unassigned_match.id }

        expect(patient_data).to include(
          "id"         => unassigned_match.id,
          "first_name" => unassigned_match.first_name,
          "last_name"  => unassigned_match.last_name,
          "email"      => unassigned_match.email
        )
        expect(patient_data["indication"]).to include("id" => diabetes.id, "name" => diabetes.name)
      end

      it "returns an empty array when no available patients exist" do
        Patient.where(indication: diabetes, doctor_id: nil).destroy_all

        get "/api/v1/doctors/#{doctor.id}/available_patients"

        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to eq([])
      end

      it "works for a doctor with multiple indications" do
        multi_indication_doctor = create(:doctor, indications: [diabetes, hair_loss])
        hair_loss_patient = create(:patient, indication: hair_loss)

        get "/api/v1/doctors/#{multi_indication_doctor.id}/available_patients"

        ids = JSON.parse(response.body).map { |p| p["id"] }
        expect(ids).to include(unassigned_match.id, hair_loss_patient.id)
      end
    end

    context "when doctor does not exist" do
      it "returns 404" do
        get "/api/v1/doctors/99999/available_patients"

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end