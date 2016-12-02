class AddZoneNameToCodeProcess < ActiveRecord::Migration[5.0]
  def change
    add_column :code_processes, :zone_name, :string
  end
end
