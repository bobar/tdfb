class AddFirstLastNameToUsers < ActiveRecord::Migration
  def change
    add_column :users, :first_name, :string, after: :name
    add_column :users, :last_name, :string, after: :first_name
  end
end
