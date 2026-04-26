class CreateDoctorIndications < ActiveRecord::Migration[7.0]
  def change
    create_table :doctor_indications do |t|
      t.references :doctor, null: false, foreign_key: true
      t.references :indication, null: false, foreign_key: true

      t.timestamps
    end

    add_index :doctor_indications, [:doctor_id, :indication_id], unique: true
  end
end
