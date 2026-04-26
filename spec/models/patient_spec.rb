require 'rails_helper'

RSpec.describe Patient, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:indication).optional }
    it { is_expected.to belong_to(:doctor).optional }
    it { is_expected.to have_many(:appointments).dependent(:nullify) }
  end

  describe "validations" do
    subject { build(:patient) }

    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
  end

  describe "scopes" do
    describe ".unassigned" do
      it "returns patients without a doctor" do
        unassigned = create(:patient)
        create(:patient, doctor: create(:doctor))

        expect(Patient.unassigned).to contain_exactly(unassigned)
      end
    end

    describe ".assigned" do
      it "returns patients with a doctor" do
        doctor = create(:doctor)
        assigned = create(:patient, doctor: doctor)
        create(:patient)

        expect(Patient.assigned).to contain_exactly(assigned)
      end
    end

    describe ".sorted_by_last_name" do
      it "returns patients ordered alphabetically by last name" do
        charlie = create(:patient, last_name: "Charlie")
        alice   = create(:patient, last_name: "Alice")
        bob     = create(:patient, last_name: "Bob")

        expect(Patient.sorted_by_last_name).to eq([alice, bob, charlie])
      end
    end

    describe ".sorted_by_closest_appointment" do
      it "returns patients ordered by their next future appointment, patients without future appointments last" do
        doctor = create(:doctor)

        patient_no_appt  = create(:patient, doctor: doctor)
        patient_far      = create(:patient, doctor: doctor)
        patient_soon     = create(:patient, doctor: doctor)

        create(:appointment, patient: patient_far,  doctor: doctor, scheduled_at: 10.days.from_now)
        create(:appointment, patient: patient_soon, doctor: doctor, scheduled_at: 2.days.from_now)

        result = doctor.patients.sorted_by_closest_appointment
        expect(result.map(&:id)).to eq([patient_soon.id, patient_far.id, patient_no_appt.id])
      end
    end
  end
end