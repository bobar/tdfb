class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.string :trigramme, limit: 3
      t.integer :frankiz_id
      t.string :name
      t.date :birthdate
      t.string :nickname
      t.string :casert
      t.integer :status
      t.string :group
      t.integer :promo
      t.string :email
      t.string :picture, limit: 1000
      t.decimal :balance, null: false, scale: 2, precision: 11, default: 0
      t.decimal :turnover, null: false, scale: 2, precision: 11, default: 0
      t.timestamps null: true
    end

    add_index :accounts, :trigramme, unique: true
    add_index :accounts, :frankiz_id, unique: true
  end
end
