# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
# player: {:name=>"Babe Ruth", "WAR"=>"182.6", "AB"=>"8399", "position"=>"H", "H"=>"2873", "HR"=>"714", "BA"=>".342", "R"=>"2174", "RBI"=>"2214", "SB"=>"123"}}name: Babe Ruthplayer: {"Walter Johnson"=>{:name=>"Walter Johnson", "WAR"=>"165.1", "W"=>"417", "position"=>"P", "L"=>"279", "ERA"=>"2.17", "G"=>"802", "GS"=>"666", "SV"=>"34"} ayer: {:name=>"Cy Young", "WAR"=>"163.6", "W"=>"511", "position"=>"P", "L"=>"315", "ERA"=>"2.63", "G"=>"906", "GS"=>"815", "SV"=>"18"}
p "seeding players"
Player.create_players(10)