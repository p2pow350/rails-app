class CreateCodes < ActiveRecord::Migration
  def change
    create_table :codes do |t|
      t.string :name
      t.string :prefix
      t.references :zone, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
