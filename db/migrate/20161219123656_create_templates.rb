class CreateTemplates < ActiveRecord::Migration[5.0]
  def change
    create_table :templates do |t|
      t.string :name
      t.integer :header_rows
      t.integer :sheet
      t.integer :zone_col
      t.integer :prefix_col
      t.integer :price_col
      t.integer :date_col

      t.timestamps
    end
  end
end
