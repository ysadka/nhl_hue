Having some fun with the NHL playoffs and lights!

On a hue:
- The light will turn red and flash for ~15 seconds on a goal
- If the game is tied then the light is white
- If a team is leading then the light will turn to the color of their jersey (controled in team_info.rb)

On an Arduino:
-Light is placed in port 13 and will flash any time a team scores a goal

Required Gems:

```sh
gem install nokogiri
gem install hue
gem install arduino_firmata
```

Steps to get running:

```sh
$ git clone <repo>

$ cd nhl_hue/
```

For a hue:
```sh
$ ruby hue.rb <team 1> <team 2>
```

On an Arduino with a light in port 13:

```sh
$ ruby nhl.rb <team 1> <team 2>
```
