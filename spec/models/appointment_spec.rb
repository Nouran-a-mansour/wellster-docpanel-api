require 'rails_helper'

RSpec.describe Appointment, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:patient).optional }
    it { is_expected.to belong_to(:doctor).optional }
  end

  describe "validations" do
    subject { build(:appointment) }

    it { is_expected.to validate_presence_of(:scheduled_at) }

    describe "scheduled_at_cannot_be_in_the_past" do
      it "is invalid when scheduled_at is in the past" do
        appointment = build(:appointment, scheduled_at: 1.day.ago)
        expect(appointment).not_to be_valid
        expect(appointment.errors[:scheduled_at]).to include("cannot be in the past")
      end

      it "is valid when scheduled_at is in the future" do
        appointment = build(:appointment, scheduled_at: 1.day.from_now)
        expect(appointment).to be_valid
      end

      it "does not validate on update" do
        appointment = create(:appointment, scheduled_at: 1.day.from_now)
        appointment.update!(scheduled_at: 1.day.ago)
        expect(appointment).to be_valid
      end
    end
  end
end