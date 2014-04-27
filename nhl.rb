require "rubygems"
require "arduino_firmata"
require "nokogiri"
require "open-uri"
require_relative "team_info.rb"

ARDUINO = ArduinoFirmata.connect
puts "firmata version #{ARDUINO.version}"

ARDUINO.digital_write 13, false
p "It's game time!!"

def go_crazy(n)
  n.times do
    ARDUINO.digital_write 13, true
    sleep 0.2
    ARDUINO.digital_write 13, false
    sleep 0.05
  end
end

def pull_info(team, data)
  TEAM_INFO[team.to_sym][data]
end

def update_score(team)
  team == 'home' ? @home += 1 : @away += 1
end

def goal(team, name)
  update_score(team)
  p "#{pull_info(name,:name)} score!!"
  p "#{pull_info(ARGV[0],:name)}: #{@home} - #{pull_info(ARGV[1],:name)}: #{@away}"
  go_crazy(30)
end

def set_time(time)
  @time = time
end

def check_time(time)
  p "#{time}"
  sleep 120 if time.downcase.include?("end")
  sleep 10 if time.downcase == @time
  set_time(time)
end

def game_update(match)
  check_time(match.first.text)
  match.each_with_index do |elem, i|
    if elem.text.downcase == ARGV[0]
      goal('home', ARGV[0]) if match[i+2].text.to_i > @home
    elsif elem.text.downcase == ARGV[1]
      goal('away', ARGV[1]) if match[i+2].text.to_i > @away
    end
  end
end

def desired_update?(match)
  ARGV[0].downcase == (match[1].text.downcase || match[3].text.downcase)
end

###### Driver Code #######
@home = 0
@away = 0
@time = ''

doc = Nokogiri::HTML(open("http://www.nhl.com/"))
@games = doc.children.children.children.children.children.children.children.children.children.children.children.each_slice(7).to_a

while @time != 'FINAL'
  @games.each do |match|
    desired_update?(match) ? game_update(match) : next
  end

  sleep 2
end
