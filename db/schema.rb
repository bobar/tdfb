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

ActiveRecord::Schema.define(version: 20170621181432) do

  create_table "accounts", force: :cascade do |t|
    t.string  "trigramme",    limit: 3
    t.integer "frankiz_id",   limit: 4
    t.text    "name",         limit: 65535,             null: false
    t.text    "first_name",   limit: 65535,             null: false
    t.text    "nickname",     limit: 65535,             null: false
    t.date    "birthdate"
    t.text    "casert",       limit: 255,               null: false
    t.integer "status",       limit: 4
    t.integer "promo",        limit: 4
    t.text    "mail",         limit: 65535,             null: false
    t.text    "picture",      limit: 65535,             null: false
    t.integer "balance",      limit: 4,     default: 0, null: false
    t.integer "turnover",     limit: 4,     default: 0, null: false
    t.integer "total_clopes", limit: 4,     default: 0, null: false
  end

  add_index "accounts", ["frankiz_id"], name: "unique_account_frankiz_id", unique: true, using: :btree
  add_index "accounts", ["trigramme"], name: "trigramme", using: :btree

  create_table "admins", force: :cascade do |t|
    t.integer "permissions", limit: 4
    t.text    "passwd",      limit: 255
  end

  create_table "clopes", force: :cascade do |t|
    t.text    "marque",   limit: 255
    t.integer "prix",     limit: 4
    t.integer "quantite", limit: 4
  end

  create_table "droits", primary_key: "permissions", force: :cascade do |t|
    t.string  "nom",            limit: 20,                 null: false
    t.boolean "log_eleve",                 default: false, null: false
    t.boolean "credit",                    default: false, null: false
    t.boolean "log_groupe",                default: false, null: false
    t.boolean "transfert",                 default: false, null: false
    t.boolean "creer_tri",                 default: false, null: false
    t.boolean "modifier_tri",              default: false, null: false
    t.boolean "supprimer_tri",             default: false, null: false
    t.boolean "somme_tri",                 default: false, null: false
    t.boolean "voir_comptes",              default: false, null: false
    t.boolean "debit_fichier",             default: false, null: false
    t.boolean "export",                    default: false, null: false
    t.boolean "reinitialiser",             default: false, null: false
    t.boolean "super_admin",               default: false, null: false
    t.boolean "banque_binet",              default: false, null: false
    t.boolean "gestion_clopes",            default: false, null: false
    t.boolean "gestion_admin",             default: false, null: false
  end

  create_table "event_comments", force: :cascade do |t|
    t.integer  "event_id",   limit: 4,     null: false
    t.integer  "author_id",  limit: 4,     null: false
    t.text     "comment",    limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "event_transactions", force: :cascade do |t|
    t.integer  "event_id",   limit: 4,                 null: false
    t.integer  "account_id", limit: 4,                 null: false
    t.string   "trigramme",  limit: 3,                 null: false
    t.string   "first_name", limit: 255,               null: false
    t.string   "last_name",  limit: 255,               null: false
    t.decimal  "price",                  precision: 2, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "event_transactions", ["event_id"], name: "fk_rails_62eab051bc", using: :btree

  create_table "events", force: :cascade do |t|
    t.string   "name",         limit: 255,             null: false
    t.date     "date",                                 null: false
    t.string   "binet_id",     limit: 255,             null: false
    t.integer  "requester_id", limit: 4,               null: false
    t.integer  "status",       limit: 4,   default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "schema_migrations_public", id: false, force: :cascade do |t|
    t.string "version", limit: 255, null: false
  end

  add_index "schema_migrations_public", ["version"], name: "unique_schema_migrations_public", unique: true, using: :btree

  create_table "transactions", force: :cascade do |t|
    t.integer  "buyer_id",    limit: 4
    t.integer  "amount",      limit: 4
    t.text     "comment",     limit: 16777215
    t.integer  "admin",       limit: 4
    t.integer  "receiver_id", limit: 4
    t.boolean  "is_tobacco",                   default: false, null: false
    t.datetime "date"
  end

  add_index "transactions", ["buyer_id", "date"], name: "id_date", using: :btree

  create_table "transactions_history", id: false, force: :cascade do |t|
    t.integer  "id",      limit: 4
    t.integer  "price",   limit: 4
    t.text     "comment", limit: 65535
    t.integer  "admin",   limit: 4
    t.integer  "id2",     limit: 4
    t.datetime "date"
  end

  add_index "transactions_history", ["id", "date"], name: "id_date", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "first_name", limit: 255
    t.string   "last_name",  limit: 255
    t.string   "email",      limit: 255
    t.string   "promo",      limit: 255
    t.string   "group",      limit: 255
    t.string   "sport",      limit: 255
    t.string   "casert",     limit: 255
    t.string   "picture",    limit: 255
    t.date     "birthdate"
    t.integer  "frankiz_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["frankiz_id"], name: "index_users_on_frankiz_id", unique: true, using: :btree

  create_table "wrong_ids", force: :cascade do |t|
    t.integer  "frankiz_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_foreign_key "event_transactions", "events"
end
