class AddStatusToCarrier < ActiveRecord::Migration[5.0]
  def change
    add_column :carriers, :status, :boolean
  end
end
