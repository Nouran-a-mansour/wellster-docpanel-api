class DoctorIndication < ApplicationRecord
  belongs_to :doctor
  belongs_to :indication

  validates :doctor_id, uniqueness: { scope: :indication_id }
end