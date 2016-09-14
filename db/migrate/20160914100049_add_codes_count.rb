class AddCodesCount < ActiveRecord::Migration[5.0]
  def change
    add_column :zones, :codes_count, :integer, default: 0
  end
end
