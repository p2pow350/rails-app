class AddFlagsToRates < ActiveRecord::Migration[5.0]
  def change
    add_column :rates, :flag1, :string
    add_column :rates, :flag2, :string
    add_column :rates, :flag3, :string
  end
end
