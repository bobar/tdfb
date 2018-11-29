class DropWrongIds < ActiveRecord::Migration
  def change
    drop_table "wrong_ids" do |t|
      t.integer  "frankiz_id", limit: 4
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end
