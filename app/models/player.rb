# require 'rest-client'
require 'nokogiri'
class Player < ApplicationRecord
    has_many :sessions, foreign_key: 'current_player_id'
    
    PITCHER_STATS = ["W", "L", "SO", "ERA", "IP", "SV"]
    HITTER_STATS = ["HITS", "BA", "HR", "RUNS", "RBI", "SB", "AB"]

    def self.create_player(player)
        name = player["name"]
        war = player["WAR"].to_f
        images = player["images"]
        image = images[0]
        secondary_image = images[1]
        if player["player_type"] == "P"
            wins = player ["W"].to_i
            losses = player["L"].to_i
            strikeouts = player["SO"].to_i
            era = player["ERA"].to_f
            ip = player["IP"].to_f
            saves = player["SV"].to_i
            walks = player["BB"].to_i
            shutouts = player["SHO"].to_i
            hits = player["H"].to_i
            new_player = Player.create(role: "pitcher", name: name, war: war, image: image, wins: wins, losses: losses, strikeouts: strikeouts, era: era, ip: ip, saves: saves, image_secondary: secondary_image, walks: walks, shutouts: shutouts, hits: hits)
        elsif player["player_type"] == "H"
            hits = player["H"].to_i
            avg = player["BA"].to_f
            hr = player["HR"].to_i
            runs = player["R"].to_i
            obs = player["onbase_perc"].to_f
            rbi = player["RBI"].to_i
            sb = player["SB"].to_i
            steals = player["SB"].to_i
            caught_stealing = player["CS"].to_i
            walks = player["BB"].to_i
            doubles = player["2B"].to_i
            triples = player["3B"].to_i
            slg_pct = player["slugging_perc"].to_f
            at_bats = player["AB"].to_i
            new_player = Player.create(role: "hitter", name: name, war: war, image: image, hits: hits, avg: avg, hr: hr, runs: runs, rbi: rbi, stolen_bases: sb, at_bats: at_bats, image_secondary: secondary_image, walks: walks, doubles: doubles, triples: triples, slg_pct: slg_pct, obs: obs, caught_stealing: caught_stealing, steals: steals)
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

            if Player.find_by(name: player_name)
                p "Player #{player_name} already exists"
                next
            end
            player = 'https://www.baseball-reference.com'.concat(player[:link])
            page = Nokogiri::HTML(RestClient.get(player, {}))

            stats_pullout = page.at_css('.stats_pullout')
            war = stats_pullout&.at_css(".p1")&.at_css("div")&.css("p")&.last&.text
            images = page.at_css('.media-item').css('img').map do |img|
                img.attribute('src').value
            end
            stat_hash = {"name"=> player_name, "images"=> images, "WAR"=> war}
            stat_footer =  page.at_css("tfoot")
            final_stats= stat_footer.at_css("tr")
            stat_footer.at_css("tr")
            final_stats.children.each do |child|
                if child.name == "td"
                   stat_attr = child&.attribute("data-stat")&.value
                   stat_value = child&.children&.first&.text
                   stat_hash[stat_attr] = stat_value
                   if !stat_hash["player_type"]
                        if HITTER_STATS.include?(stat_attr)
                            stat_hash["player_type"] = "H"
                        elsif PITCHER_STATS.include?(stat_attr)
                            stat_hash["player_type"] = "P"
                        end
                    end
                end
            end
            Player.create_player(stat_hash)
            sleep(5)
        end
    end
end
