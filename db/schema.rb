# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170305155820) do

  create_table "accounts", force: :cascade do |t|
    t.string   "trigramme",  limit: 3
    t.integer  "frankiz_id", limit: 4
    t.string   "name",       limit: 255
    t.date     "birthdate"
    t.string   "nickname",   limit: 255
    t.string   "casert",     limit: 255
    t.integer  "status",     limit: 4
    t.string   "group",      limit: 255
    t.integer  "promo",      limit: 4
    t.string   "email",      limit: 255
    t.string   "picture",    limit: 1000
    t.decimal  "balance",                 precision: 11, scale: 2, default: 0.0, null: false
    t.decimal  "turnover",                precision: 11, scale: 2, default: 0.0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "accounts", ["frankiz_id"], name: "index_accounts_on_frankiz_id", unique: true, using: :btree
  add_index "accounts", ["trigramme"], name: "index_accounts_on_trigramme", unique: true, using: :btree

  create_table "transactions", force: :cascade do |t|
    t.decimal  "price",                   precision: 11, scale: 2, default: 0.0, null: false
    t.string   "comment",     limit: 255
    t.integer  "payer_id",    limit: 4
    t.integer  "receiver_id", limit: 4
    t.integer  "admin_id",    limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "transactions", ["admin_id"], name: "fk_rails_6e14efbab8", using: :btree
  add_index "transactions", ["payer_id", "created_at"], name: "index_transactions_on_payer_id_and_created_at", using: :btree
  add_index "transactions", ["receiver_id"], name: "fk_rails_d261c16c42", using: :btree

  create_table "wrong_frankiz_ids", force: :cascade do |t|
    t.integer  "frankiz_id", limit: 4, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "wrong_frankiz_ids", ["frankiz_id"], name: "index_wrong_frankiz_ids_on_frankiz_id", unique: true, using: :btree

  add_foreign_key "transactions", "accounts", column: "admin_id", on_update: :cascade, on_delete: :nullify
  add_foreign_key "transactions", "accounts", column: "payer_id", on_update: :cascade, on_delete: :nullify
  add_foreign_key "transactions", "accounts", column: "receiver_id", on_update: :cascade, on_delete: :nullify
end
