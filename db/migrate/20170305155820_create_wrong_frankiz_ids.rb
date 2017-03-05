class CreateWrongFrankizIds < ActiveRecord::Migration
  def change
    create_table :wrong_frankiz_ids do |t|
      t.integer :frankiz_id, null: false
      t.timestamps null: true
    end

    add_index :wrong_frankiz_ids, :frankiz_id, unique: true
  end
end
