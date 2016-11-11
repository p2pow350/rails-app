class AddCodeToRates < ActiveRecord::Migration[5.0]
  def change
    add_reference :rates, :code, foreign_key: true
  end
end
