class AddUniqueIndexOnFrankizId < ActiveRecord::Migration
  def change
    add_index :accounts, :frankiz_id, unique: true, name: :unique_account_frankiz_id
  end
end
