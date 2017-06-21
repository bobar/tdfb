class AddCigarettesToTransactions < ActiveRecord::Migration
  def change
    add_column :transactions, :is_tobacco, :boolean, null: false, default: false, after: :id2
  end
end
