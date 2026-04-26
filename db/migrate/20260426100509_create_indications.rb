class CreateIndications < ActiveRecord::Migration[7.0]
  def change
    create_table :indications do |t|
      t.string :name, null: false

      t.timestamps
    end
    add_index :indications, :name, unique: true
  end
end
