class AddAreaToStations < ActiveRecord::Migration[5.1]
  def change
    add_column :stations, :area, :string
  end
end
