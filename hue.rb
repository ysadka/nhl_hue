require "rubygems"
require "nokogiri"
require "open-uri"
require "hue"
require_relative "team_info.rb"

p "It's game time!!"
p "With HUE!!"

def set_light_color
  tie_game? ? turn_light('white') : set_to_jersey_color
end

def turn_light(color)
  p "Turning light #{color}"
  @light.set_state(LIGHT_COLORS[color.to_sym])
end

def tie_game?
  @home == @away
end

def leader
  @home > @away ? ARGV[0] : ARGV[1]
end

def set_to_jersey_color
  turn_light(TEAM_INFO[leader.to_sym][:jersey_color])
end

def flash_light
  @light.set_state({ alert: "lselect" })
end

def go_crazy
  turn_light('red')
  flash_light
  sleep 15
  set_light_color
end

def score(team, name)
  team == 'home' ? @home += 1 : @away += 1
  p "#{name} scores!!"
  p "#{ARGV[0]}: #{@home} - #{ARGV[1]}: #{@away}"
  go_crazy
end

def check_time(time)
  p "#{time}"
  sleep 120 if time.downcase.include?("end")
  sleep 10 if time.downcase == @time
end

def game_update(match)
  check_time(match.first.text)
  match.each_with_index do |elem, i|
    if elem.text.downcase == ARGV[0]
      if match[i+2].text.to_i > @home
        score('home', ARGV[0])
      end
    elsif elem.text.downcase == ARGV[1]
      if match[i+2].text.to_i > @away
        score('away', ARGV[1])
      end
    end
  end
  @time = match.first.text
end

def desired_update?(match)
  ARGV[0].downcase == match[1].children.text.downcase || ARGV[0].downcase == match[4].children.text.downcase
end

hue = Hue::Client.new
@light = hue.lights.first
@light.on = true
turn_light('white')

@home = 0
@away = 0
@time = ''

while true
  doc = Nokogiri::HTML(open("http://www.nhl.com/"))
  games = doc.children.children.children.children.children.children.children.children.children.children.children.each_slice(7).to_a

  games.each do |match|
    match
    desired_update?(match) ? game_update(match) : next
  end

  sleep 2
end
