require "rubygems"
require "arduino_firmata"
require "nokogiri"
require "open-uri"

ARDUINO = ArduinoFirmata.connect
puts "firmata version #{ARDUINO.version}"

@home = 0
@away = 0
@time = ''

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

def score(team, name)
  team == 'home' ? @home += 1 : @away += 1
  p "#{name} scores!!"
  p "#{ARGV[0]}: #{@home} - #{ARGV[1]}: #{@away}"
  go_crazy(30)
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
  ARGV[0].downcase == (match[1].text.downcase || match[3].text.downcase)
end

while true
  doc = Nokogiri::HTML(open("http://www.nhl.com/"))
  games = doc.children.children.children.children.children.children.children.children.children.children.children.each_slice(7).to_a

  games.each do |match|
    match
    desired_update?(match) ? game_update(match) : next
  end

  sleep 2
end
