class RenameOptionKeyColumn < ActiveRecord::Migration[5.0]
  def change
    rename_column :options, :key, :o_key
  end
end
