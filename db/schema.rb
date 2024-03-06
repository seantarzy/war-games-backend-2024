# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2024_03_05_070515) do
  create_table "games", force: :cascade do |t|
    t.string "invite_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "players", force: :cascade do |t|
    t.string "role"
    t.string "name"
    t.integer "war"
    t.string "image"
    t.string "image_secondary"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "wins"
    t.integer "losses"
    t.float "era"
    t.integer "strikeouts"
    t.float "ip"
    t.integer "saves"
    t.integer "at_bats"
    t.integer "hits"
    t.float "avg"
    t.integer "hr"
    t.integer "runs"
    t.integer "rbi"
    t.integer "stolen_bases"
    t.integer "walks"
    t.integer "doubles"
    t.integer "triples"
    t.float "slg_pct"
    t.float "obs"
    t.integer "shutouts"
    t.integer "caught_stealing"
    t.integer "steals"
  end

  create_table "session_games", force: :cascade do |t|
    t.integer "session_id", null: false
    t.integer "game_id", null: false
    t.integer "current_player_id"
    t.integer "current_score", default: 0
    t.boolean "active", default: false
    t.integer "refreshes", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["current_player_id"], name: "index_session_games_on_current_player_id"
    t.index ["game_id"], name: "index_session_games_on_game_id"
    t.index ["session_id"], name: "index_session_games_on_session_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.integer "wins", default: 0
    t.integer "losses", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "session_games", "games"
  add_foreign_key "session_games", "players", column: "current_player_id"
  add_foreign_key "session_games", "sessions"
end
