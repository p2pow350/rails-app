class AddCodeToCodeProcess < ActiveRecord::Migration[5.0]
  def change
    add_reference :code_processes, :code, foreign_key: true
  end
end
