class CreateCarriers < ActiveRecord::Migration
  def change
    create_table :carriers do |t|
      t.string :name
      t.boolean :is_customer
      t.boolean :is_supplier

      t.timestamps null: false
    end
  end
end
