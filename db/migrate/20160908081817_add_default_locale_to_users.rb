class AddDefaultLocaleToUsers < ActiveRecord::Migration
  def change
    add_column :users, :default_locale, :string
  end
end
