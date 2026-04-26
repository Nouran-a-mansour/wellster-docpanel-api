class Appointment < ApplicationRecord
  belongs_to :patient, optional: true
  belongs_to :doctor, optional: true

  validates :scheduled_at, presence: true
  validate :scheduled_at_cannot_be_in_the_past, on: :create

  private

  def scheduled_at_cannot_be_in_the_past
    return if scheduled_at.blank?

    errors.add(:scheduled_at, :cannot_be_in_past) if scheduled_at < Time.current

  end
end