# require 'rest-client'
require 'nokogiri'
class Player < ApplicationRecord
    has_many :sessions, foreign_key: 'current_player_id'
    
    PITCHER_STATS = ["W", "L", "SO", "ERA", "IP", "SV"]
    HITTER_STATS = ["HITS", "BA", "HR", "RUNS", "RBI", "SB", "AB"]

    def self.create_player(player)
        name = player["name"]
        war = player["WAR"]
        images = player["images"]
        image = images[0]
        secondary_image = images[1]
        if player["player_type"] == "P"
            wins = player ["W"]
            losses = player["L"]
            strikeouts = player["SO"]
            era = player["ERA"]
            ip = player["IP"]
            saves = player["SV"]
            new_player = Player.create(role: "pitcher", name: name, war: war, image: image, wins: wins, losses: losses, strikeouts: strikeouts, era: era, ip: ip, saves: saves, image_secondary: secondary_image)
        elsif player["player_type"] == "H"
            hits = player["H"]
            avg = player["BA"]
            hr = player["HR"]
            runs = player["R"]
            rbi = player["RBI"]
            sb = player["SB"]
            at_bats = player["AB"]
            new_player = Player.create(role: "hitter", name: name, war: war, image: image, hits: hits, avg: avg, hr: hr, runs: runs, rbi: rbi, stolen_bases: sb, at_bats: at_bats, image_secondary: secondary_image)
        end
        if new_player.valid?
            p "Player #{new_player.name} created"
        else
            p "Player #{new_player.name} not created"
        end
    end

    def self.player_names_with_links
        request = RestClient.get('https://www.baseball-reference.com/leaders/WAR_career.shtml',{})
        doc = Nokogiri::HTML(request)
        table = doc.css("#leader_standard_WAR")
        player_names_with_links = table.first.children.map do |row|
           td = row&.children[1]
           name = td&.at_css("a")&.children&.first&.text&.split("+")&.first|| nil
           link = td&.at_css("a")&.attribute("href")&.value || nil
            if name && link
                {name: name, link: link}
            end   
        end.compact # Remove any nil values from the array
    end


    def self.create_players
        player_names_with_links.map do |player|
            player_name = player[:name]
            player = 'https://www.baseball-reference.com'.concat(player[:link])
            page = Nokogiri::HTML(RestClient.get(player, {}))
            images = page.at_css('.media-item').css('img').map do |img|
                img.attribute('src').value
            end
            stats_pullout = page.at_css('.stats_pullout')
            stat_hash = {"name"=> player_name, "images"=> images}
            first_set_of_stats = stats_pullout.at_css('.p1')
            first_set_of_stats.children.each do |child|
                if child.name != "text"
                    stat_attr = child.at_css("span").children.first.children.first.text
                    stat_val = child.at_css("p").children.first.text
                    stat_hash[stat_attr] = stat_val
                    if !stat_hash["player_type"]
                        if HITTER_STATS.include?(stat_attr)
                            stat_hash["player_type"] = "H"
                        elsif PITCHER_STATS.include?(stat_attr)
                            stat_hash["player_type"] = "P"
                        end
                    end
                end
            end
            second_set_of_stats = stats_pullout.at_css('.p2')
            second_set_of_stats.children.each do |child|
                if child.name != "text"
                    stat_attr = child.at_css("span").children.first.children.first.text
                    stat_val = child.at_css("p").children.first.text
                    stat_hash[stat_attr] = stat_val
                end
            end
            Player.create_player(stat_hash)
            sleep(5)
        end
    end
end
