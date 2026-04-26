require 'rails_helper'

RSpec.describe Doctor, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:doctor_indications).dependent(:destroy) }
    it { is_expected.to have_many(:indications).through(:doctor_indications) }
    it { is_expected.to have_many(:patients).dependent(:nullify) }
    it { is_expected.to have_many(:appointments).dependent(:nullify) }
  end

  describe "validations" do
    subject { build(:doctor) }

    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
  end

  describe "#available_patients" do
    let(:diabetes) { create(:indication, name: "Diabetes") }
    let(:hair_loss) { create(:indication, name: "Hair Loss") }
    let(:doctor) { create(:doctor, indications: [diabetes]) }

    it "returns unassigned patients with matching indication" do
      matching = create(:patient, indication: diabetes)
      create(:patient, indication: hair_loss)
      create(:patient, indication: diabetes, doctor: doctor)

      expect(doctor.available_patients).to contain_exactly(matching)
    end

    it "returns empty when no unassigned matching patients exist" do
      create(:patient, indication: diabetes, doctor: doctor)

      expect(doctor.available_patients).to be_empty
    end
  end
end