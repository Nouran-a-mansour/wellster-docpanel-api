require 'rails_helper'

RSpec.describe "Api::V1::Doctors::Patients", type: :request do
  let(:indication) { create(:indication) }
  let(:doctor) { create(:doctor, indications: [indication]) }

  describe "GET /api/v1/doctors/:doctor_id/patients" do
    context "when doctor exists" do
      let!(:patient_z) { create(:patient, last_name: "Zara",  doctor: doctor, indication: indication) }
      let!(:patient_a) { create(:patient, last_name: "Adams", doctor: doctor, indication: indication) }
      let!(:patient_m) { create(:patient, last_name: "Miller", doctor: doctor, indication: indication) }

      it "returns assigned patients sorted by last name by default" do
        get "/api/v1/doctors/#{doctor.id}/patients"

        expect(response).to have_http_status(:ok)
        last_names = JSON.parse(response.body).map { |p| p["last_name"] }
        expect(last_names).to eq(["Adams", "Miller", "Zara"])
      end

      it "returns patients sorted by last name when sort=last_name" do
        get "/api/v1/doctors/#{doctor.id}/patients", params: { sort: "last_name" }

        expect(response).to have_http_status(:ok)
        last_names = JSON.parse(response.body).map { |p| p["last_name"] }
        expect(last_names).to eq(["Adams", "Miller", "Zara"])
      end

      it "returns patients sorted by closest appointment when sort=closest_appointment" do
        create(:appointment, patient: patient_m, doctor: doctor, scheduled_at: 2.days.from_now)
        create(:appointment, patient: patient_a, doctor: doctor, scheduled_at: 7.days.from_now)

        get "/api/v1/doctors/#{doctor.id}/patients", params: { sort: "closest_appointment" }

        expect(response).to have_http_status(:ok)
        ids = JSON.parse(response.body).map { |p| p["id"] }
        expect(ids).to eq([patient_m.id, patient_a.id, patient_z.id])
      end

      it "includes next_appointment in the response" do
        appt = create(:appointment, patient: patient_a, doctor: doctor, scheduled_at: 3.days.from_now)

        get "/api/v1/doctors/#{doctor.id}/patients"

        body = JSON.parse(response.body)
        patient_response = body.find { |p| p["id"] == patient_a.id }
        expect(patient_response["next_appointment"]).to be_present
      end

      it "returns next_appointment as nil when patient has no future appointments" do
        past_appt = build(:appointment, patient: patient_a, doctor: doctor, scheduled_at: 2.days.ago)
        past_appt.save!(validate: false)

        get "/api/v1/doctors/#{doctor.id}/patients"

        body = JSON.parse(response.body)
        patient_response = body.find { |p| p["id"] == patient_a.id }
        expect(patient_response["next_appointment"]).to be_nil
      end

      it "does not return patients assigned to other doctors" do
        other_doctor = create(:doctor, indications: [indication])
        other_patient = create(:patient, doctor: other_doctor, indication: indication)

        get "/api/v1/doctors/#{doctor.id}/patients"

        ids = JSON.parse(response.body).map { |p| p["id"] }
        expect(ids).not_to include(other_patient.id)
      end
    end

    context "when doctor does not exist" do
      it "returns 404" do
        get "/api/v1/doctors/99999/patients"

        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "POST /api/v1/doctors/:doctor_id/patients" do
    context "when assignment is valid" do
      let(:patient) { create(:patient, indication: indication) }

      it "assigns the patient to the doctor" do
        post "/api/v1/doctors/#{doctor.id}/patients",
             params: { patient: { patient_id: patient.id } }

        expect(response).to have_http_status(:created)
        expect(patient.reload.doctor_id).to eq(doctor.id)
      end

      it "returns the assigned patient" do
        post "/api/v1/doctors/#{doctor.id}/patients",
             params: { patient: { patient_id: patient.id } }

        body = JSON.parse(response.body)
        expect(body["id"]).to eq(patient.id)
        expect(body["indication"]["name"]).to eq(indication.name)
      end
    end

    context "when patient is already assigned to a doctor" do
      let(:other_doctor) { create(:doctor, indications: [indication]) }
      let(:patient) { create(:patient, indication: indication, doctor: other_doctor) }

      it "returns 422" do
        post "/api/v1/doctors/#{doctor.id}/patients",
             params: { patient: { patient_id: patient.id } }

        expect(response).to have_http_status(:unprocessable_content)
        expect(JSON.parse(response.body)["error"]).to include("already assigned")
      end
    end

    context "when patient indication does not match doctor's indications" do
      let(:other_indication) { create(:indication) }
      let(:patient) { create(:patient, indication: other_indication) }

      it "returns 422" do
        post "/api/v1/doctors/#{doctor.id}/patients",
             params: { patient: { patient_id: patient.id } }

        expect(response).to have_http_status(:unprocessable_content)
        expect(JSON.parse(response.body)["error"]).to include("not qualified")
      end
    end

    context "when doctor does not exist" do
      let(:patient) { create(:patient, indication: indication) }

      it "returns 404" do
        post "/api/v1/doctors/99999/patients",
             params: { patient: { patient_id: patient.id } }

        expect(response).to have_http_status(:not_found)
      end
    end

    context "when patient does not exist" do
      it "returns 404" do
        post "/api/v1/doctors/#{doctor.id}/patients",
             params: { patient: { patient_id: 99999 } }

        expect(response).to have_http_status(:not_found)
      end
    end
  end
end