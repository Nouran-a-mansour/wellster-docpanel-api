class Patient < ApplicationRecord
  belongs_to :indication, optional: true
  belongs_to :doctor, optional: true
  has_many :appointments, dependent: :nullify

  validates :first_name, :last_name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }

  scope :unassigned, -> { where(doctor_id: nil) }
  scope :assigned, -> { where.not(doctor_id: nil) }

  scope :sorted_by_last_name, -> { order(:last_name) }
  scope :sorted_by_closest_appointment, lambda {
    left_joins(:appointments)
      .where("appointments.scheduled_at > ? OR appointments.id IS NULL", Time.current)
      .group("patients.id")
      .order(Arel.sql("MIN(appointments.scheduled_at) ASC NULLS LAST"))
  }
end