class AddCarrierToCodeProcess < ActiveRecord::Migration[5.0]
  def change
    add_reference :code_processes, :carrier, foreign_key: true
  end
end
