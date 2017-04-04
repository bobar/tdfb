class StoreUsersPicture < ActiveRecord::Migration
  def change
    add_column :users, :picture, :string, after: :casert
  end
end
