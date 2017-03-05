class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.decimal :price, null: false, default: 0, scale: 2, precision: 11
      t.string :comment
      t.integer :payer_id
      t.integer :receiver_id
      t.integer :admin_id
      t.timestamps null: true
    end

    add_index :transactions, [:payer_id, :created_at]

    add_foreign_key :transactions, :accounts, column: :payer_id, on_update: :cascade, on_delete: :nullify
    add_foreign_key :transactions, :accounts, column: :receiver_id, on_update: :cascade, on_delete: :nullify
    add_foreign_key :transactions, :accounts, column: :admin_id, on_update: :cascade, on_delete: :nullify
  end
end
