class AddColumnsToVehicle < ActiveRecord::Migration[5.1]
  def change
    add_column :vehicles, :brand, :string
    add_column :vehicles, :model, :string
  end
end
