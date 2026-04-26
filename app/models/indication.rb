class Indication < ApplicationRecord
  has_many :doctor_indications, dependent: :destroy
  has_many :doctors, through: :doctor_indications
  has_many :patients, dependent: :nullify

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end