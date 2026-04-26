class CreatePatients < ActiveRecord::Migration[7.0]
  def change
    create_table :patients do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :email, null: false
      t.references :indication, null: true, foreign_key: true
      t.references :doctor, null: true, foreign_key: true

      t.timestamps
    end
    add_index :patients, :email, unique: true
  end
end
