class CreateAppointments < ActiveRecord::Migration[7.0]
  def change
    create_table :appointments do |t|
      t.references :patient, null: true, foreign_key: true
      t.references :doctor, null: true, foreign_key: true
      t.datetime :scheduled_at, null: false

      t.timestamps
    end
  end
end
