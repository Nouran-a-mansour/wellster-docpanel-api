class Doctor < ApplicationRecord
  has_many :doctor_indications, dependent: :destroy
  has_many :indications, through: :doctor_indications
  has_many :patients, dependent: :nullify
  has_many :appointments, dependent: :nullify

  validates :first_name, :last_name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }

  def available_patients
    Patient.unassigned.where(indication_id: indication_ids)
  end
end