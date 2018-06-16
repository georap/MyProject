class CreateVehicles < ActiveRecord::Migration[5.1]
  def change
    create_table :vehicles do |t|
      t.string :name
      t.integer :kilometers
      t.float :liters
      t.date :fuel_date
      t.string :fuel_type
      t.string :area
      t.references :user, foreign_key: true
      t.references :station, foreign_key: true

      t.timestamps
    end
  end
end
