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

ActiveRecord::Schema.define(version: 20161115213542) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "games", force: :cascade do |t|
    t.datetime "date"
    t.integer  "home_score"
    t.integer  "away_score"
    t.string   "neutral"
    t.integer  "overtime"
    t.string   "home_team"
    t.string   "away_team"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "games_teams", id: false, force: :cascade do |t|
    t.integer "game_id"
    t.integer "team_id"
    t.index ["game_id"], name: "index_games_teams_on_game_id", using: :btree
    t.index ["team_id"], name: "index_games_teams_on_team_id", using: :btree
  end

  create_table "players", force: :cascade do |t|
    t.text     "name"
    t.float    "rating"
    t.float    "ortg"
    t.float    "drtg"
    t.integer  "team_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["team_id", "rating"], name: "index_players_on_team_id_and_rating", using: :btree
    t.index ["team_id"], name: "index_players_on_team_id", using: :btree
  end

  create_table "teams", force: :cascade do |t|
    t.string   "school_name"
    t.string   "nickname"
    t.decimal  "rating"
    t.decimal  "ortg"
    t.decimal  "drtg"
    t.decimal  "tempo"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "team_page"
    t.string   "schedule_page"
    t.string   "conference"
    t.decimal  "point_margin"
    t.integer  "rank"
    t.integer  "wins"
    t.integer  "losses"
    t.integer  "conf_wins"
    t.integer  "conf_losses"
    t.index ["school_name"], name: "index_teams_on_school_name", unique: true, using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "first_name"
    t.string   "email"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.string   "password_digest"
    t.string   "favorites",       default: [],              array: true
    t.string   "last_name"
    t.string   "remember_digest"
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
  end

  add_foreign_key "players", "teams"
end
