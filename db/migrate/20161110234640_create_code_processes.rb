class CreateCodeProcesses < ActiveRecord::Migration[5.0]
  def change
    create_table :code_processes do |t|
      t.references :zone, foreign_key: true
      t.string :carrier_zone_name
      t.string :prefix
      t.string :carrier_prefix
      t.date :start_date
      t.decimal :carrier_price1
      t.string :flag_update1
      t.decimal :carrier_price2
      t.string :flag_update2
      t.decimal :carrier_price3
      t.string :flag_update3
      t.decimal :carrier_price4
      t.string :flag_update4

      t.timestamps
    end
  end
end
