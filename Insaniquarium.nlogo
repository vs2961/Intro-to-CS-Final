breed [fish fishe]
breed [pellets pellet]
breed [shop-items shop-item]
breed [prices price]
breed [bosses boss]
breed [lasers laser]
breed [buttons button]
breed [carnivores carnivore]
fish-own [hungry? time-to-death chasing sleep food-to-grow time-to-money]
prices-own [priced]
shop-items-own [items]
breed [mouses mouse]
bosses-own [health hit edge me]
pellets-own [time down? collect]
carnivores-own [hungry? time-to-death chasing sleep time-to-money]
globals [game cooldown cooldown-pellets money check-money suspend my-pellet egg-state time-to-boss warned boss-wave next-laser my-pellet-num my-laser]

to setup
  clear-turtles
  reset-ticks
  resize-world 0 625 0 474
  set game false
  create-mouses 1 [set hidden? true]
  import-pcolors-rgb "/home/victor/Downloads/2.jpg"
  create-buttons 35 [
    set shape "circle"
    set hidden? true
    set size 20
    setxy 220 + (who * 5) 46
  ]
end

to setup2
  ca
  reset-ticks
  set game true
  set suspend false
  set boss-wave false
  set money 200
  set check-money 200
  set-patch-size 1
  set time-to-boss 5000
  set my-pellet 1
  set my-pellet-num 1
  set warned false
  set my-laser 1
  import-pcolors-rgb "/home/victor/Downloads/I3-2.png"
  create-prices 1 [setxy 567 423 set label-color green set priced 200 set label money]
  create-mouses 1 [set hidden? true]
  create-buttons 13 [
    setxy 529 + (who * 5) 457
    set shape "circle"
    set hidden? true
    set size 20
  ]
  create-fish 2 [
    set shape "fish-small-l"
    set size 50
    setxy random-xcor (random 300) + 40
    set heading 270
    set hungry? false
    set time-to-death (random 500) + 500
    set chasing false
    set sleep false
    set food-to-grow 4
    set time-to-money 100
    set color yellow
  ]
end

to go
  ifelse game [
    ifelse money > check-money [set money check-money update-money]
    [set check-money money update-money]
    ask mouses [setxy mouse-xcor mouse-ycor]
    ifelse not suspend [
      set cooldown cooldown - 1
      set cooldown-pellets cooldown-pellets - 1
      set time-to-boss time-to-boss - 1
      manage-pellets
      manage-fish
      manage-carnivores
      ifelse boss-wave [
        fight-boss
      ]
      [drop-pellets]
      manage-boss
      if mouse-down? and cooldown < 1 [
        itemcheck
        set cooldown 12
      ]
      if count carnivores with [not sleep] < 1 and count fish with [not sleep] < 1 and not suspend [
        game-over
      ]
      if mouse-ycor > 400 and mouse-xcor > 492 [
        ask buttons [
          if mouse-down? [
            if count mouses in-radius 10 > 0 [
              set game false
            ]
          ]
        ]
        if not game [setup]
      ]
    ]
    [setup]
  ]
  [
    ask mouses [setxy mouse-xcor mouse-ycor]
    ask buttons [
      if mouse-down? [
        if count mouses in-radius 10 > 0 [
          set game true
        ]
      ]
    ]
    if game [
      setup2
    ]
  ]
  tick
end

to drop-pellets
  if mouse-down? and mouse-ycor < 390 and cooldown-pellets < 1 and count pellets with [shape != "coin" and shape != "diamond"] < my-pellet-num and money >= 5[
    set money money - 5
    set cooldown-pellets 5
    update-money
    let x ""
    if my-pellet = 1 [
      set x "pellet"
    ]
    if my-pellet = 2 [
      set x "pellet2"
    ]
    if my-pellet = 3 [
      set x "pellet3"
    ]
    create-pellets 1 [set collect false set shape x setxy mouse-xcor mouse-ycor + 20 set size 35 set heading 180 set down? false]
  ]
end

to update-money
  set check-money money
  ask price 0 [
    if money > 9999999 [
      set money 9999999
    ]
    set label money
    set xcor 550 + (8 * (length (word money) - 1))
  ]
end

to manage-carnivores
  ask carnivores [
    set time-to-money time-to-money - 1
    if not boss-wave [
      set time-to-death time-to-death - 1
    ]
    if time-to-death < 1 [
      set sleep true
      ifelse shape = "carnivore-sick-l" [
        set shape "carnivore-sleep-l"
      ]
      [set shape "carnivore-sleep-r"]
    ]
    drop-money
    if time-to-death < 300 and not hungry? [
      set hungry? true
      ifelse shape = "carnivore-l" [
        set shape "carnivore-sick-l"
      ]
      [set shape "carnivore-sick-r"]
    ]
    ifelse not hungry? [
      move
    ]
    [sick-move
      if chasing [
        repeat 40 [
          fd 0.1
          if count fish with [size < 100] in-radius 10 > 0 [
            ask fish with [size < 100] in-radius 10 [
              die
            ]
            set hungry? false
            set time-to-death (random 500) + 1000
            ifelse shape = "carnivore-sick-r" [
              set shape "carnivore-r"
            ]
            [set shape "carnivore-l"]
          ]
        ]
      ]
    ]
  ]
end

to manage-fish
  ask fish [
    if size > 50 [
      set time-to-money time-to-money - 1
    ]
    if not boss-wave [
      set time-to-death time-to-death - 1
    ]
    if time-to-death < 1 [
      set sleep true
      ifelse shape = "fish-sick-r-s" [
        set shape "fish-sleep-r-s"
      ]
      [set shape "fish-sleep-l-s"]
    ]
    drop-money
    if time-to-death < 300 and not hungry? [
      set hungry? true
      ifelse shape = "fish-small-r" [
        set shape "fish-sick-r-s"
      ]
      [set shape "fish-sick-l-s"]
    ]
    if food-to-grow < 1 [
      if size = 150 and (random (6 - my-pellet)) = 0 [
        set color cyan
      ]
      if size = 100 [
        set size 150
        set food-to-grow 15
      ]
      if size = 50 [
        set size 100
        set food-to-grow 6
      ]
    ]
    ifelse not hungry? [
      move
    ]
    [sick-move
      if chasing [
        repeat 40 [
          fd 0.1
          if count pellets with [shape != "coin" and shape != "diamond"] in-radius 10 > 0 [
            ask pellets with [shape != "coin" and shape != "diamond"] in-radius 10 [
              die
            ]
            set hungry? false
            set food-to-grow food-to-grow - my-pellet
            set time-to-death (random 500) + 500
            ifelse shape = "fish-sick-r-s" [
              set shape "fish-small-r"
            ]
            [set shape "fish-small-l"]
          ]
        ]
      ]
    ]
  ]
end

to manage-pellets
  ask pellets [
    if (shape = "coin" or shape = "diamond") and count mouses in-radius 10 > 0 [
      face patch 561 419
      set collect true
      set down? false
    ]
    ifelse ycor < 50 and not down? and not collect [
      ifelse shape = "coin" or shape = "diamond" [
        set time 500
      ]
      [set time 50]
      set down? true
    ]
    [ifelse down? [
      set time time - 1
      if time < 1 [
        die
      ]
     ]
      [fd 2
        if collect [
          repeat 18 [
            fd 1.3
            if ycor > 400 [
              ifelse shape = "diamond" [
                set money money + 100
              ]
              [
                if color = 36 [
                  set money money + 15
                ]
                if color = 45 [
                  set money money + 35
                ]
              ]
              update-money
              die
            ]
          ]
        ]
      ]
    ]
  ]
end

to drop-money
  if time-to-money < 1 and size > 50 [
    let x 36
    if size = 150 [
      set x 45
    ]
    set time-to-money 500
    ifelse color != cyan [
      hatch-pellets 1 [set ycor ycor - 10 set shape "coin" set color x set down? false set size 30 set heading 180 set collect false]
    ]
    [hatch-pellets 1 [set ycor ycor - 10 set shape "diamond" set color x set down? false set size 30 set heading 180 set collect false]]
  ]
end

to itemcheck
  if mouse-ycor > 400 [
    ask shop-items [
      ifelse mouse-down? and count mouses in-radius 30 > 0 and cooldown < 1 [
        buy items
      ]
      [stop]
    ]
  ]
  if ticks > 300 and count shop-items < 1[
    create-shop-items 1 [set shape "fish-item1" setxy 45.5 453 set size 65 set items "fish" set color violet - 2]
    create-prices 1 [setxy 52 420 set label-color green set priced 100 set label (word "$" priced)]
  ]
  if ticks > 3000 and count shop-items < 2 and my-pellet < 2[
    create-shop-items 1 [set shape "pellet-item1" setxy 108.5 450 set size 65 set items "pellet" set color violet - 2]
    create-prices 1 [setxy 122 420 set label-color green set priced 200 set label (word "$" priced)]
  ]
  if ticks > 3000 and count prices with [xcor = 179] < 1 [
    create-shop-items 1 [set shape "two-pellets" setxy 164.5 450 set size 70 set items "pellet-num" set color violet - 2]
    create-prices 1 [setxy 179 420 set label-color green set priced 200 set label (word "$" priced)]
  ]
  if ticks > 5000 and count shop-items with [shape = "carnivore-item"] < 1 [
    create-shop-items 1 [set shape "carnivore-item" setxy 238.5 450 set size 45 set items "carnivore" set color violet - 2]
    create-prices 1 [setxy 257 420 set label-color green set priced 1000 set label (word "$" priced)]
  ]
  if ticks > 7000 and my-laser < 2 and count prices with [xcor = 330] < 1 [
    create-shop-items 1 [set shape "laser-1" setxy 311.5 450 set size 68 set items "laser" set color violet - 2]
    create-prices 1 [setxy 330 420 set label-color green set priced 1000 set label (word "$" priced)]
  ]
  if ticks > 10000 and count shop-items with [shape = "egg-piece-1" or shape = "egg-piece-2" or shape = "egg-piece-3"] < 1 [
    create-shop-items 1 [set shape "egg-piece-1" setxy 384.5 450 set size 65 set items "egg" set color violet - 2]
    create-prices 1 [setxy 403 420 set label-color green set priced 2000 set label (word "$" priced)]
  ]
end

to buy [bought-item]
  if bought-item = "fish" and money >= 100 [
    set money money - 100
    update-money
    hatch-fish 1 [
      set shape "fish-small-l"
      set size 50
      set color yellow
      setxy random-xcor (random 300) + 10
      set heading 270
      set hungry? false
      set time-to-death (random 1000) + 500
      set chasing false
      set sleep false
      set food-to-grow 4
      set time-to-money 0
    ]
  ]
  if bought-item = "pellet" and money >= 200 and my-pellet < 3 [
    set money money - 200
    update-money
    set my-pellet my-pellet + 1
    ifelse my-pellet = 2 [
      ask shop-items with [shape = "pellet-item1"] [set shape "pellet-item2"]
    ]
    [ask prices with [xcor = 122] [set label "MAX"]
      ask shop-items with [shape = "pellet-item2"] [die]]
  ]
  if bought-item = "pellet-num" and money >= 200 and my-pellet-num <= 5 and cooldown < 1 [
    set cooldown 12
    set money money - 200
    update-money
    set my-pellet-num my-pellet-num + 1
    ifelse my-pellet-num < 5 [
      ifelse my-pellet-num = 4 [
        ask shop-items with [shape = "four-pellets"] [set shape "five-pellets"]
      ]
      [
        ifelse my-pellet-num = 3 [
          ask shop-items with [shape = "three-pellets"] [set shape "four-pellets"]
        ]
        [if my-pellet-num = 2 [
          ask shop-items with [shape = "two-pellets"] [set shape "three-pellets"]
          ]
        ]
      ]
    ]
    [ask prices with [xcor = 179] [set label "MAX"]
      ask shop-items with [shape = "five-pellets"] [die]
    ]
  ]
  if bought-item = "carnivore" and money >= 1000 [
    set money money - 1000
    update-money
    hatch-carnivores 1 [
      set shape "carnivore-l"
      set size 100
      setxy random-xcor (random 300) + 10
      set heading 270
      set color cyan
      set hungry? false
      set time-to-death (random 1000) + 1000
      set chasing false
      set sleep false
      set time-to-money 0
    ]
  ]
  if bought-item = "laser" and money >= 1000 and my-laser <= 10 and cooldown < 1 [
    set cooldown 12
    set money money - 1000
    update-money
    set my-laser my-laser * 2
    ifelse my-laser < 10 [
      ifelse my-laser = 8 [
        ask shop-items with [shape = "laser-3"] [set shape "laser-4"]
      ]
      [
        ifelse my-laser = 4 [
          ask shop-items with [shape = "laser-2"] [set shape "laser-3"]
        ]
        [if my-laser = 2 [
          ask shop-items with [shape = "laser-1"] [set shape "laser-2"]
          ]
        ]
      ]
    ]
    [ask prices with [xcor = 330] [set label "MAX" set xcor xcor - 4]
      ask shop-items with [shape = "laser-4"] [die]
    ]
  ]
  if bought-item = "egg" and money >= 2000 and my-pellet <= 3 [
    set money money - 2000
    update-money
    if egg-state = 0 [
      ask shop-items with [shape = "egg-piece-1"] [set shape "egg-piece-2"]
    ]
    if egg-state = 1 [
      ask shop-items with [shape = "egg-piece-2"] [set shape "egg-piece-3"]
    ]
    if egg-state = 2 [
      win
    ]
    set egg-state egg-state + 1
  ]

end

to move
  fd 2
  if xcor < 100 [
    set heading 90
    ifelse breed = fish [
      ifelse not hungry? [
        set shape "fish-small-r"
      ]
      [set shape "fish-sick-r-s"]
    ]
    [ifelse not hungry? [
        set shape "carnivore-r"
      ]
      [set shape "carnivore-sick-r"]
    ]
  ]
  if xcor > 565 [
    set heading 270
    ifelse breed = fish [
      ifelse not hungry? [
        set shape "fish-small-l"
      ]
      [set shape "fish-sick-l-s"]
    ]
    [ifelse not hungry? [
        set shape "carnivore-l"
      ]
      [set shape "carnivore-sick-l"]
    ]
  ]
  if ticks mod 20 = 0 [
    ifelse shape = "fish-small-r" or shape = "fish-sick-r-s" or shape = "carnivore-r" or shape = "carnivore-sick-r" [
      set heading 130 - (random 80)
      if ycor > 350 [
        set heading heading + 30
      ]
      if ycor < 100 [
        set heading heading - 30
      ]
    ]
    [
      set heading 310 - (random 80)
      if ycor > 350 [
        set heading heading - 30
      ]
      if ycor < 100 [
        set heading heading + 30
      ]
    ]
  ]
end

to sick-move
  ifelse sleep [
    set heading 0
    fd 1.5
    if ycor > 375 [
      die
    ]
  ]
  [
    ifelse ticks mod 30 = 0 [
      ifelse breed = fish [
        ifelse count pellets with [shape != "coin" and shape != "diamond"] in-radius 500 > 0 [
          face min-one-of pellets with [shape != "coin" and shape != "diamond"] [distance myself]
          set chasing true
        ]
        [move]
      ]
      [ifelse count fish with [size < 100] in-radius 500 > 0 [
          face min-one-of fish with [size < 100] [distance myself]
          set chasing true
        ]
        [move]
      ]
    ]
    [ifelse chasing [
      carefully [
        ifelse breed = fish [
          face min-one-of pellets with [shape != "coin" and shape != "diamond"] [distance myself]
          ifelse heading > 180 [
            set shape "fish-sick-l-s"
          ]
          [set shape "fish-sick-r-s"]
        ]
        [face min-one-of fish with [size < 100] [distance myself]
          ifelse heading > 180 [
            set shape "carnivore-sick-l"
          ]
          [set shape "carnivore-sick-r"]
        ]
      ]
      [set chasing false]
      ]
      [move]
    ]
  ]
end

to manage-boss
  if not warned and time-to-boss < 1 [
    set warned true
    set time-to-boss 150
    create-prices 1 [setxy 250 10 set shape "boss-warning-1" set size 70]
    create-prices 1 [setxy 330 10 set shape "boss-warning-2" set size 70]
    create-prices 1 [setxy 395 12 set shape "boss-warning-3" set size 70]
  ]
  if time-to-boss < 1 and not boss-wave and warned [
    create-bosses 1 [
      setxy random-xcor (random 300) + 50
      set shape one-of ["alien-1-r" "lion-boss-l"]
      ifelse shape = "alien-1-r" [
        set me 1
      ]
      [set me 2]
      set color orange - 1
      set size 200
      set health 40
    ]
    ask prices with [ycor < 20] [die]
    set boss-wave true
  ]
  ask bosses [
    fd 2.5
    set hit hit - 1
    carefully [
      if hit < 1 [
        face min-one-of fish with [not sleep] [distance myself]
      ]
    ]
    [game-over]
    if health < 1 [
      set boss-wave false
      set warned false
      set time-to-boss 5000
      ask lasers [die]
      hatch-pellets 1 [
        set shape "diamond"
        set down? false
        set size 30
        set heading 180
        set collect false
        if xcor < 50 [
          set xcor 50
        ]
        if xcor > 575 [
          set xcor 575
        ]
      ]
      die
    ]
    ifelse heading < 180 [
      ifelse me = 1 [
        set shape "alien-1-r"
      ]
      [set shape "lion-boss-r"]
    ]
    [ifelse me = 1 [
      set shape "alien-1-l"
      ]
      [set shape "lion-boss-l"]
    ]
    if ticks mod 5 = 0 [
      if count fish in-radius 20 > 0 [
        ask fish in-radius 10 [
          ifelse shape = "fish-sick-r-s" or shape = "fish-small-r" [
            set shape "fish-sleep-r-s"
          ]
          [set shape "fish-sleep-l-s"]
          set time-to-death 0
        ]
      ]
    ]
  ]
end

to fight-boss
  set next-laser next-laser - 1
  ask lasers [
    set size size - 30
    if size < 1 [die]
  ]
  if next-laser < 1 and mouse-ycor < 410 [
    create-lasers 1 [set shape "dot" set color white setxy mouse-xcor mouse-ycor set size 100]
    ask patch mouse-xcor mouse-ycor [
      ask bosses in-radius 100 [
        set health health - my-laser
        face patch mouse-xcor mouse-ycor
        set heading heading + 180
        ifelse ycor > 100 and ycor < 300 and xcor > 90 and xcor < 530 [
          set hit 10
          fd 10
        ]
        [recoil]
        ifelse heading < 180 [
          ifelse me = 1 [
            set shape "alien-1-r"
          ]
          [set shape "lion-boss-r"]
        ]
        [ifelse me = 1 [
          set shape "alien-1-l"
          ]
          [set shape "lion-boss-l"]
        ]
      ]
    ]
    set next-laser 10
  ]
end

to recoil
  if (ycor < 100 and xcor < 90) or (ycor < 100 and xcor > 530) or (ycor > 300 and xcor < 90) or (ycor > 300 and xcor > 530) [
    set hit 10
  ]
  if (ycor < 100 and heading >= 180) or (ycor > 300 and heading >= 180) [
    set heading 270
    fd 10
    set hit 10
  ]
  if (ycor < 100 and heading < 180) or (ycor > 300 and heading < 180) [
    set heading 90
    fd 10
    set hit 10
  ]
end

to game-over
  user-message "Sorry, game over. All your fish have died."
  set suspend true
  ask fish [die]
  ask bosses [die]
end

to win
  user-message "Good job!"
  set suspend true
end
@#$#@#$#@
GRAPHICS-WINDOW
202
10
836
494
-1
-1
1.0
1
13
1
1
1
0
0
0
1
0
625
0
474
1
1
1
ticks
30.0

BUTTON
83
44
157
77
NIL
Setup
NIL
1
T
OBSERVER
NIL
S
NIL
NIL
1

BUTTON
89
91
152
124
NIL
go
T
1
T
OBSERVER
NIL
G
NIL
NIL
0

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

alien-1-l
false
0
Polygon -13345367 true false 107 95 108 81 117 65 132 48 157 45 182 45 195 51 181 80 167 119 154 129 146 128 126 126 123 122
Polygon -13345367 true false 171 100 184 98 194 105 210 94 232 98 238 126 239 158 230 141 243 170 250 192
Polygon -13345367 true false 144 128 148 137 132 142 130 149 130 153 93 185 72 185 75 199 95 206 101 196 143 167 139 161 150 153 156 171 158 171 183 237 183 260 168 264 195 265 203 229 216 215 233 212 246 187 170 96
Polygon -13345367 true false 242 180 256 172 259 182 241 193
Polygon -1 true false 74 186 61 185 57 187 78 192
Polygon -1 true false 81 190 74 201 86 194
Polygon -1 true false 104 198 102 200
Polygon -1 true false 91 193 97 197 90 216
Polygon -2674135 true false 109 94 148 95 123 117
Line -16777216 false 198 135 219 172
Line -16777216 false 217 173 197 219
Polygon -1 true false 109 93 115 99 115 95
Polygon -1 true false 111 95 114 104 114 96
Polygon -1 true false 116 96 118 105 119 92 114 95
Polygon -1 true false 122 97 120 93 125 93 123 103
Polygon -1 true false 117 110 118 101 123 108 119 108
Polygon -1 true false 119 113 118 106 127 115 126 103 132 111 120 116
Polygon -1 true false 192 217 175 224 192 223
Polygon -1 true false 200 224 201 244 208 224
Polygon -1 true false 196 226 190 242 191 224

alien-1-r
false
0
Polygon -13345367 true false 193 95 192 81 183 65 168 48 143 45 118 45 105 51 119 80 133 119 146 129 154 128 174 126 177 122
Polygon -13345367 true false 129 100 116 98 106 105 90 94 68 98 62 126 61 158 70 141 57 170 50 192
Polygon -13345367 true false 156 128 152 137 168 142 170 149 170 153 207 185 228 185 225 199 205 206 199 196 157 167 161 161 150 153 144 171 142 171 117 237 117 260 132 264 105 265 97 229 84 215 67 212 54 187 130 96
Polygon -13345367 true false 58 180 44 172 41 182 59 193
Polygon -1 true false 226 186 239 185 243 187 222 192
Polygon -1 true false 219 190 226 201 214 194
Polygon -1 true false 196 198 198 200
Polygon -1 true false 209 193 203 197 210 216
Polygon -2674135 true false 191 94 152 95 177 117
Line -16777216 false 102 135 81 172
Line -16777216 false 83 173 103 219
Polygon -1 true false 191 93 185 99 185 95
Polygon -1 true false 189 95 186 104 186 96
Polygon -1 true false 184 96 182 105 181 92 186 95
Polygon -1 true false 178 97 180 93 175 93 177 103
Polygon -1 true false 183 110 182 101 177 108 181 108
Polygon -1 true false 181 113 182 106 173 115 174 103 168 111 180 116
Polygon -1 true false 108 217 125 224 108 223
Polygon -1 true false 100 224 99 244 92 224
Polygon -1 true false 104 226 110 242 109 224

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

boss-warning-1
false
0
Polygon -7500403 true true 31 92
Polygon -13840069 true false 29 92 28 162 41 162 44 92
Polygon -13840069 true false 37 94 70 96
Polygon -13840069 true false 36 167 54 167 64 164 66 160 67 155 65 135 58 135 59 156 33 155
Polygon -13840069 true false 42 124 66 124 65 135 35 134
Polygon -13840069 true false 39 92 57 92 67 95 69 99 70 104 68 124 61 124 62 103 36 104
Polygon -13840069 true false 82 128 93 128 107 152 124 128 133 128 108 169
Polygon -13840069 true false 82 128 93 128 107 104 124 128 133 128 108 87
Polygon -13840069 true false 187 88 152 89 150 126 190 127 189 165 153 162 157 173 202 172 200 114 163 114 163 100 192 100
Polygon -13840069 true false 255 88 220 89 218 126 258 127 257 165 221 162 225 173 270 172 268 114 231 114 231 100 260 100

boss-warning-2
false
0
Rectangle -13840069 true false 30 90 75 105
Rectangle -13840069 true false 45 105 60 165
Rectangle -13840069 true false 30 165 75 180
Rectangle -13840069 true false 90 90 105 180
Rectangle -13840069 true false 135 90 150 180
Polygon -13840069 true false 119 91 152 182
Polygon -13840069 true false 105 90 135 150 135 180 105 120
Polygon -13840069 true false 195 90 165 135 195 180 210 180 180 135 210 90 195 90
Polygon -13840069 true false 210 135 240 180 270 135 255 135 240 165 225 135
Polygon -13840069 true false 210 135 240 90 270 135 255 135 240 105 225 135

boss-warning-3
false
0
Polygon -13840069 true false 45 90
Rectangle -13840069 true false 0 105 15 180
Rectangle -13840069 true false 60 105 75 180
Polygon -13840069 true false 45 105
Polygon -13840069 true false 45 105
Polygon -13840069 true false 15 120 30 150 45 150 60 120 60 105 51 105 38 136 23 105 0 105
Polygon -13840069 true false 121 105
Polygon -13840069 true false 120 105
Rectangle -13840069 true false 90 105 135 120
Rectangle -13840069 true false 105 120 120 180
Rectangle -13840069 true false 90 165 135 180
Rectangle -13840069 true false 150 105 165 180
Rectangle -13840069 true false 195 105 210 180
Polygon -13840069 true false 165 105 195 150 195 180 165 135
Polygon -13840069 true false 255 105 225 135 240 180 270 180 285 165 255 165 240 135 255 120 270 120 270 105
Rectangle -13840069 true false 255 135 285 150
Rectangle -13840069 true false 270 150 285 165

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

carnivore-item
false
4
Circle -1184463 true true 0 0 300
Polygon -16777216 true false 224 150 230 161 238 149 230 155 158 177 119 221 126 225 131 228 157 243 175 250 188 259 202 258 209 258 220 255 236 247 233 245 228 242 223 237 216 232 211 222 206 211 196 209 205 170 187 201 207 167 225 185 219 192 220 201 220 201 233 219 241 225 246 239 249 242 253 250 259 254 259 254 269 254 277 258 270 232 270 213 266 201 259 169 263 148 264 112 265 96 271 94 251 74 245 84 242 89
Polygon -16777216 true false 87 67 104 50 110 52 125 41 130 42 141 39 144 39 154 30 190 30 190 35 203 36 210 44 212 44 222 49 237 52 216 73 211 71 204 80 184 82 177 94 173 96 173 109 176 115 186 116 186 124 204 122 218 125 219 116 219 116 232 98 240 92 245 78 248 75 252 67 258 63 258 63 268 63 276 59 269 85 269 104 265 116 258 148 262 169 263 205 264 221 270 223 250 243 244 233 241 228
Circle -7500403 true false 60 94 140
Circle -7500403 true false 46 67 122
Polygon -7500403 true false 71 104
Polygon -7500403 true false 63 86 46 102 47 107 40 114 37 127 33 139 25 158 16 185 42 189 51 199 41 201 32 206 21 208 49 223 60 222
Polygon -16777216 true false 90 222 83 234 84 259 99 252 105 244 113 232
Polygon -16777216 true false 66 195 50 240 50 240 58 253 80 252
Polygon -2674135 true false 60 180
Polygon -1 true false 31 185 38 193 39 190 42 194 44 190 47 194 49 192 52 196 54 191 56 188
Polygon -1 true false 37 209 40 196 43 203 44 198 48 202 49 198 52 203 54 198 59 201
Circle -1184463 true true 45 152 37
Circle -16777216 true false 55 161 18
Circle -1 true false 60 158 10
Polygon -2674135 true false 30 210 60 201 59 191 81 192 89 187 98 176 102 157 111 174 119 181 144 128 150 136 158 145 166 138 181 154 192 130 198 145 217 134 221 160 224 188 217 186 210 208 161 237 162 234 152 236 135 238 120 238 109 224 95 236 71 224 45 225
Polygon -16777216 true false 249 125 248 150 241 174 254 214 254 226 264 260 251 255 238 253 222 225 206 163

carnivore-l
false
2
Polygon -16777216 true false 239 150 245 161 253 149 245 155 173 177 134 221 141 225 146 228 172 243 190 250 203 259 217 258 224 258 235 255 251 247 248 245 243 242 238 237 231 232 226 222 221 211 211 209 220 170 202 201 222 167 240 185 234 192 235 201 235 201 248 219 256 225 261 239 264 242 268 250 274 254 274 254 284 254 292 258 285 232 285 213 281 201 274 169 278 148 279 112 280 96 286 94 266 74 260 84 257 89
Polygon -16777216 true false 102 67 119 50 125 52 140 41 145 42 156 39 159 39 169 30 205 30 205 35 218 36 225 44 227 44 237 49 252 52 231 73 226 71 219 80 199 82 192 94 188 96 188 109 191 115 201 116 201 124 219 122 233 125 234 116 234 116 247 98 255 92 260 78 263 75 267 67 273 63 273 63 283 63 291 59 284 85 284 104 280 116 273 148 277 169 278 205 279 221 285 223 265 243 259 233 256 228
Circle -7500403 true false 60 94 140
Circle -7500403 true false 61 67 122
Polygon -7500403 true false 71 104
Polygon -7500403 true false 78 86 61 102 62 107 55 114 52 127 48 139 40 158 31 185 57 189 66 199 56 201 47 206 36 208 64 223 75 222
Polygon -16777216 true false 105 222 98 234 99 259 114 252 120 244 128 232
Polygon -16777216 true false 81 195 65 240 65 240 73 253 95 252
Polygon -2674135 true false 60 180
Polygon -1 true false 31 185 38 193 39 190 42 194 44 190 47 194 49 192 52 196 54 191 56 188
Polygon -1 true false 37 209 40 196 43 203 44 198 48 202 49 198 52 203 54 198 59 201
Circle -1184463 true false 60 152 37
Circle -16777216 true false 70 161 18
Circle -1 true false 75 158 10
Polygon -2674135 true false 39 209 60 201 59 191 81 192 89 187 98 176 102 157 111 174 119 181 144 128 150 136 158 145 166 138 181 154 192 130 198 145 217 134 221 160 224 188 217 186 210 208 161 237 162 234 152 236 135 238 120 238 109 224 95 236 71 224 40 210
Polygon -16777216 true false 279 125 278 150 271 174 284 214 284 226 294 260 281 255 268 253 252 225 236 163

carnivore-r
false
2
Polygon -16777216 true false 61 150 55 161 47 149 55 155 127 177 166 221 159 225 154 228 128 243 110 250 97 259 83 258 76 258 65 255 49 247 52 245 57 242 62 237 69 232 74 222 79 211 89 209 80 170 98 201 78 167 60 185 66 192 65 201 65 201 52 219 44 225 39 239 36 242 32 250 26 254 26 254 16 254 8 258 15 232 15 213 19 201 26 169 22 148 21 112 20 96 14 94 34 74 40 84 43 89
Polygon -16777216 true false 198 67 181 50 175 52 160 41 155 42 144 39 141 39 131 30 95 30 95 35 82 36 75 44 73 44 63 49 48 52 69 73 74 71 81 80 101 82 108 94 112 96 112 109 109 115 99 116 99 124 81 122 67 125 66 116 66 116 53 98 45 92 40 78 37 75 33 67 27 63 27 63 17 63 9 59 16 85 16 104 20 116 27 148 23 169 22 205 21 221 15 223 35 243 41 233 44 228
Circle -7500403 true false 100 94 140
Circle -7500403 true false 117 67 122
Polygon -7500403 true false 229 104
Polygon -7500403 true false 222 86 239 102 238 107 245 114 248 127 252 139 260 158 269 185 243 189 234 199 244 201 253 206 264 208 236 223 225 222
Polygon -16777216 true false 195 222 202 234 201 259 186 252 180 244 172 232
Polygon -16777216 true false 219 195 235 240 235 240 227 253 205 252
Polygon -2674135 true false 240 180
Polygon -1 true false 269 185 262 193 261 190 258 194 256 190 253 194 251 192 248 196 246 191 244 188
Polygon -1 true false 263 209 260 196 257 203 256 198 252 202 251 198 248 203 246 198 241 201
Circle -1184463 true false 203 152 37
Circle -16777216 true false 212 161 18
Circle -1 true false 215 158 10
Polygon -2674135 true false 261 209 240 201 241 191 219 192 211 187 202 176 198 157 189 174 181 181 156 128 150 136 142 145 134 138 119 154 108 130 102 145 83 134 79 160 76 188 83 186 90 208 139 237 138 234 148 236 165 238 180 238 191 224 205 236 229 224 260 210
Polygon -16777216 true false 21 125 22 150 29 174 16 214 16 226 6 260 19 255 32 253 48 225 64 163

carnivore-sick-l
false
2
Polygon -16777216 true false 239 150 245 161 253 149 245 155 173 177 134 221 141 225 146 228 172 243 190 250 203 259 217 258 224 258 235 255 251 247 248 245 243 242 238 237 231 232 226 222 221 211 211 209 220 170 202 201 222 167 240 185 234 192 235 201 235 201 248 219 256 225 261 239 264 242 268 250 274 254 274 254 284 254 292 258 285 232 285 213 281 201 274 169 278 148 279 112 280 96 286 94 266 74 260 84 257 89
Polygon -16777216 true false 102 67 119 50 125 52 140 41 145 42 156 39 159 39 169 30 205 30 205 35 218 36 225 44 227 44 237 49 252 52 231 73 226 71 219 80 199 82 192 94 188 96 188 109 191 115 201 116 201 124 219 122 233 125 234 116 234 116 247 98 255 92 260 78 263 75 267 67 273 63 273 63 283 63 291 59 284 85 284 104 280 116 273 148 277 169 278 205 279 221 285 223 265 243 259 233 256 228
Circle -10899396 true false 60 94 140
Circle -10899396 true false 61 67 122
Polygon -7500403 true false 71 104
Polygon -10899396 true false 78 86 61 102 62 107 55 114 52 127 48 139 40 158 31 185 57 189 66 199 56 201 47 206 36 208 64 223 75 222
Polygon -16777216 true false 105 222 98 234 99 259 114 252 120 244 128 232
Polygon -16777216 true false 81 195 65 240 65 240 73 253 95 252
Polygon -2674135 true false 60 180
Polygon -1 true false 31 185 38 193 39 190 42 194 44 190 47 194 49 192 52 196 54 191 56 188
Polygon -1 true false 37 209 40 196 43 203 44 198 48 202 49 198 52 203 54 198 59 201
Circle -1184463 true false 60 152 37
Circle -16777216 true false 70 161 18
Circle -1 true false 75 158 10
Polygon -10899396 true false 39 209 60 201 59 191 81 192 89 187 98 176 102 157 111 174 119 181 144 128 150 136 158 145 166 138 181 154 192 130 198 145 217 134 221 160 224 188 217 186 210 208 161 237 162 234 152 236 135 238 120 238 109 224 95 236 71 224 40 210
Polygon -16777216 true false 279 125 278 150 271 174 284 214 284 226 294 260 281 255 268 253 252 225 236 163

carnivore-sick-r
false
2
Polygon -16777216 true false 61 150 55 161 47 149 55 155 127 177 166 221 159 225 154 228 128 243 110 250 97 259 83 258 76 258 65 255 49 247 52 245 57 242 62 237 69 232 74 222 79 211 89 209 80 170 98 201 78 167 60 185 66 192 65 201 65 201 52 219 44 225 39 239 36 242 32 250 26 254 26 254 16 254 8 258 15 232 15 213 19 201 26 169 22 148 21 112 20 96 14 94 34 74 40 84 43 89
Polygon -16777216 true false 198 67 181 50 175 52 160 41 155 42 144 39 141 39 131 30 95 30 95 35 82 36 75 44 73 44 63 49 48 52 69 73 74 71 81 80 101 82 108 94 112 96 112 109 109 115 99 116 99 124 81 122 67 125 66 116 66 116 53 98 45 92 40 78 37 75 33 67 27 63 27 63 17 63 9 59 16 85 16 104 20 116 27 148 23 169 22 205 21 221 15 223 35 243 41 233 44 228
Circle -10899396 true false 100 94 140
Circle -10899396 true false 117 67 122
Polygon -7500403 true false 229 104
Polygon -10899396 true false 222 86 239 102 238 107 245 114 248 127 252 139 260 158 269 185 243 189 234 199 244 201 253 206 264 208 236 223 225 222
Polygon -16777216 true false 195 222 202 234 201 259 186 252 180 244 172 232
Polygon -16777216 true false 219 195 235 240 235 240 227 253 205 252
Polygon -2674135 true false 240 180
Polygon -1 true false 269 185 262 193 261 190 258 194 256 190 253 194 251 192 248 196 246 191 244 188
Polygon -1 true false 263 209 260 196 257 203 256 198 252 202 251 198 248 203 246 198 241 201
Circle -1184463 true false 203 152 37
Circle -16777216 true false 212 161 18
Circle -1 true false 215 158 10
Polygon -10899396 true false 261 209 240 201 241 191 219 192 211 187 202 176 198 157 189 174 181 181 156 128 150 136 142 145 134 138 119 154 108 130 102 145 83 134 79 160 76 188 83 186 90 208 139 237 138 234 148 236 165 238 180 238 191 224 205 236 229 224 260 210
Polygon -16777216 true false 21 125 22 150 29 174 16 214 16 226 6 260 19 255 32 253 48 225 64 163

carnivore-sleep-l
false
2
Polygon -16777216 true false 239 150 245 139 253 151 245 145 173 123 134 79 141 75 146 72 172 57 190 50 203 41 217 42 224 42 235 45 251 53 248 55 243 58 238 63 231 68 226 78 221 89 211 91 220 130 202 99 222 133 240 115 234 108 235 99 235 99 248 81 256 75 261 61 264 58 268 50 274 46 274 46 284 46 292 42 285 68 285 87 281 99 274 131 278 152 279 188 280 204 286 206 266 226 260 216 257 211
Polygon -16777216 true false 102 233 119 250 125 248 140 259 145 258 156 261 159 261 169 270 205 270 205 265 218 264 225 256 227 256 237 251 252 248 231 227 226 229 219 220 199 218 192 206 188 204 188 191 191 185 201 184 201 176 219 178 233 175 234 184 234 184 247 202 255 208 260 222 263 225 267 233 273 237 273 237 283 237 291 241 284 215 284 196 280 184 273 152 277 131 278 95 279 79 285 77 265 57 259 67 256 72
Circle -7500403 true false 60 66 140
Circle -7500403 true false 61 111 122
Polygon -7500403 true false 71 196
Polygon -7500403 true false 78 214 61 198 62 193 55 186 52 173 48 161 40 142 31 115 57 111 66 101 56 99 47 94 36 92 64 77 75 78
Polygon -16777216 true false 105 78 98 66 99 41 114 48 120 56 128 68
Polygon -16777216 true false 81 105 65 60 65 60 73 47 95 48
Polygon -2674135 true false 60 120
Polygon -1 true false 31 115 38 107 39 110 42 106 44 110 47 106 49 108 52 104 54 109 56 112
Polygon -1 true false 37 91 40 104 43 97 44 102 48 98 49 102 52 97 54 102 59 99
Polygon -7500403 true false 39 91 60 99 59 109 81 108 89 113 98 124 102 143 111 126 119 119 144 172 150 164 158 155 166 162 181 146 192 170 198 155 217 166 221 140 224 112 217 114 210 92 161 63 162 66 152 64 135 62 120 62 109 76 95 64 71 76 40 90
Polygon -16777216 true false 279 175 278 150 271 126 284 86 284 74 294 40 281 45 268 47 252 75 236 137
Line -16777216 false 84 128 54 143
Line -16777216 false 60 120 75 150

carnivore-sleep-r
false
2
Polygon -16777216 true false 61 150 55 139 47 151 55 145 127 123 166 79 159 75 154 72 128 57 110 50 97 41 83 42 76 42 65 45 49 53 52 55 57 58 62 63 69 68 74 78 79 89 89 91 80 130 98 99 78 133 60 115 66 108 65 99 65 99 52 81 44 75 39 61 36 58 32 50 26 46 26 46 16 46 8 42 15 68 15 87 19 99 26 131 22 152 21 188 20 204 14 206 34 226 40 216 43 211
Polygon -16777216 true false 198 233 181 250 175 248 160 259 155 258 144 261 141 261 131 270 95 270 95 265 82 264 75 256 73 256 63 251 48 248 69 227 74 229 81 220 101 218 108 206 112 204 112 191 109 185 99 184 99 176 81 178 67 175 66 184 66 184 53 202 45 208 40 222 37 225 33 233 27 237 27 237 17 237 9 241 16 215 16 196 20 184 27 152 23 131 22 95 21 79 15 77 35 57 41 67 44 72
Circle -7500403 true false 100 66 140
Circle -7500403 true false 117 111 122
Polygon -7500403 true false 229 196
Polygon -7500403 true false 222 214 239 198 238 193 245 186 248 173 252 161 260 142 269 115 243 111 234 101 244 99 253 94 264 92 236 77 225 78
Polygon -16777216 true false 195 78 202 66 201 41 186 48 180 56 172 68
Polygon -16777216 true false 219 105 235 60 235 60 227 47 205 48
Polygon -2674135 true false 240 120
Polygon -1 true false 269 115 262 107 261 110 258 106 256 110 253 106 251 108 248 104 246 109 244 112
Polygon -1 true false 263 91 260 104 257 97 256 102 252 98 251 102 248 97 246 102 241 99
Polygon -7500403 true false 261 91 240 99 241 109 219 108 211 113 202 124 198 143 189 126 181 119 156 172 150 164 142 155 134 162 119 146 108 170 102 155 83 166 79 140 76 112 83 114 90 92 139 63 138 66 148 64 165 62 180 62 191 76 205 64 229 76 260 90
Polygon -16777216 true false 21 175 22 150 29 126 16 86 16 74 6 40 19 45 32 47 48 75 64 137
Line -16777216 false 216 128 246 143
Line -16777216 false 240 120 225 150

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

coin
false
0
Circle -7500403 true true 74 74 152
Polygon -6459832 true false 180 105 30 90
Rectangle -16777216 true false 116 101 182 118
Rectangle -16777216 true false 116 110 132 145
Rectangle -16777216 true false 117 140 192 155
Rectangle -16777216 true false 181 149 193 189
Rectangle -16777216 true false 122 171 187 190
Rectangle -16777216 true false 142 87 155 203

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

diamond
false
0
Polygon -11221820 true false 75 120 120 75 180 75 225 120 150 225 75 120
Line -16777216 false 120 75 105 135
Line -16777216 false 75 120 105 135
Line -16777216 false 105 135 135 135
Line -16777216 false 135 135 195 135
Line -16777216 false 225 120 195 135
Line -16777216 false 180 75 195 135
Line -16777216 false 150 75 150 135
Line -16777216 false 105 135 150 225
Line -16777216 false 150 135 150 225
Line -16777216 false 195 135 150 225
Circle -1 true false 124 101 18

dot
false
0
Circle -7500403 true true 90 90 120

egg-piece-1
false
0
Circle -7500403 true true 45 45 210
Polygon -6459832 true false 107 188 110 195 116 197 130 209 159 210 170 199 179 194 183 186 175 177 155 172 138 174 127 174 118 178
Polygon -16777216 true false 115 186 124 179 137 177 152 177 159 177 171 180 172 185 164 185 149 186 129 190

egg-piece-2
false
0
Circle -7500403 true true 43 45 212
Polygon -6459832 true false 107 188 110 195 116 197 130 209 159 210 170 199 179 194 183 186 175 177 155 172 138 174 127 174 118 178
Polygon -6459832 true false 108 184 111 195 181 187 185 176 186 147 174 146 165 148 155 150 130 150 121 150 103 148
Polygon -6459832 true false 110 157 106 146 121 129 145 126 167 130 179 136 185 149
Polygon -16777216 true false 118 145 125 138 134 136 155 136 168 136 174 143 161 147 129 148

egg-piece-3
false
0
Circle -7500403 true true 43 45 212
Polygon -6459832 true false 107 188 110 195 116 197 130 209 159 210 170 199 179 194 183 186 175 177 155 172 138 174 127 174 118 178
Polygon -6459832 true false 108 184 111 195 181 187 185 176 186 147 174 146 165 148 155 150 130 150 121 150 103 148
Polygon -6459832 true false 110 157 106 146 121 129 145 126 167 130 179 136 185 149
Polygon -6459832 true false 105 150 120 120 120 120 135 105 165 105 178 117 178 143

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish-item1
false
6
Circle -13840069 true true 19 64 201
Circle -1184463 true false 47 150 44
Circle -1184463 true false 109 119 76
Polygon -2674135 true false 40 208 43 193 34 139 52 156 57 192 42 208
Circle -1184463 true false 89 116 68
Circle -1184463 true false 74 126 48
Circle -1184463 true false 75 156 48
Polygon -2674135 true false 140 121 132 113 123 105 97 107 104 121
Circle -1184463 true false 91 139 68
Polygon -2674135 true false 129 205 116 215 117 218 142 214 148 197
Polygon -1184463 true false 56 158 62 146 66 141 71 137 79 132 88 130 93 203 85 203 77 201 71 197 63 196
Circle -1 true false 147 133 21
Circle -16777216 true false 150 138 20
Polygon -16777216 true false 184 167 161 169 182 171

fish-l
false
0
Polygon -2674135 true false 256 131 279 87 285 86 300 120 285 150 300 180 287 214 280 212 255 166
Polygon -2674135 true false 165 195 181 235 205 218 224 210 254 204 240 165
Polygon -2674135 true false 225 45 217 77 229 103 214 114 134 78 165 60
Polygon -1184463 true false 270 136 149 77 74 81 20 119 8 146 8 160 13 170 30 195 105 210 149 212 270 166
Circle -16777216 true false 55 106 30
Polygon -16777216 true false 11 164 45 159 15 175
Circle -1 true false 75 120 0

fish-r
false
0
Polygon -2674135 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -2674135 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -2674135 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -1184463 true false 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30
Polygon -16777216 true false 289 164 255 159 285 175
Circle -1 true false 225 120 0

fish-sick-l
false
0
Polygon -8630108 true false 256 131 279 87 285 86 300 120 285 150 300 180 287 214 280 212 255 166
Polygon -8630108 true false 165 195 181 235 205 218 224 210 254 204 240 165
Polygon -8630108 true false 225 45 217 77 229 103 214 114 134 78 165 60
Polygon -10899396 true false 270 136 149 77 74 81 20 119 8 146 8 160 13 170 30 195 105 210 149 212 270 166
Circle -16777216 true false 55 106 30
Polygon -16777216 true false 11 164 45 159 15 175

fish-sick-l-s
false
0
Circle -10899396 true false 209 150 44
Circle -10899396 true false 115 119 76
Polygon -8630108 true false 260 208 257 193 266 139 248 156 243 192 258 208
Circle -10899396 true false 143 116 68
Circle -10899396 true false 178 126 48
Circle -10899396 true false 177 156 48
Polygon -8630108 true false 160 121 168 113 177 105 203 107 196 121
Circle -10899396 true false 141 139 68
Polygon -8630108 true false 171 205 184 215 183 218 158 214 152 197
Polygon -10899396 true false 244 158 238 146 234 141 229 137 221 132 212 130 207 203 215 203 223 201 229 197 237 196
Circle -1 true false 132 133 21
Circle -16777216 true false 130 138 20
Polygon -16777216 true false 116 167 139 169 118 171

fish-sick-r
false
0
Polygon -8630108 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -8630108 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -8630108 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -10899396 true false 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30
Polygon -16777216 true false 289 164 255 159 285 175

fish-sick-r-s
false
0
Circle -10899396 true false 47 150 44
Circle -10899396 true false 109 119 76
Polygon -8630108 true false 40 208 43 193 34 139 52 156 57 192 42 208
Circle -10899396 true false 89 116 68
Circle -10899396 true false 74 126 48
Circle -10899396 true false 75 156 48
Polygon -8630108 true false 140 121 132 113 123 105 97 107 104 121
Circle -10899396 true false 91 139 68
Polygon -8630108 true false 129 205 116 215 117 218 142 214 148 197
Polygon -10899396 true false 56 158 62 146 66 141 71 137 79 132 88 130 93 203 85 203 77 201 71 197 63 196
Circle -1 true false 147 133 21
Circle -16777216 true false 150 138 20
Polygon -16777216 true false 184 167 161 169 182 171

fish-sleep-l-s
false
7
Circle -7500403 true false 209 106 44
Circle -7500403 true false 115 105 76
Polygon -16777216 true false 260 92 257 107 266 161 248 144 243 108 258 92
Circle -7500403 true false 143 116 68
Circle -7500403 true false 178 126 48
Circle -7500403 true false 177 96 48
Polygon -16777216 true false 160 179 168 187 177 195 203 193 196 179
Circle -7500403 true false 141 93 68
Polygon -16777216 true false 171 95 184 85 183 82 158 86 152 103
Polygon -7500403 true false 244 142 238 154 234 159 229 163 221 168 212 170 207 97 215 97 223 99 229 103 237 104
Polygon -16777216 true false 116 133 139 131 118 129
Line -16777216 false 150 150 135 165
Line -16777216 false 135 150 150 165

fish-sleep-r-s
false
7
Circle -7500403 true false 47 106 44
Circle -7500403 true false 109 105 76
Polygon -16777216 true false 40 92 43 107 34 161 52 144 57 108 42 92
Circle -7500403 true false 89 116 68
Circle -7500403 true false 74 126 48
Circle -7500403 true false 75 96 48
Polygon -16777216 true false 140 179 132 187 123 195 97 193 104 179
Circle -7500403 true false 91 93 68
Polygon -16777216 true false 129 95 116 85 117 82 142 86 148 103
Polygon -7500403 true false 56 142 62 154 66 159 71 163 79 168 88 170 93 97 85 97 77 99 71 103 63 104
Polygon -16777216 true false 184 133 161 131 182 129
Line -16777216 false 150 150 165 165
Line -16777216 false 165 150 150 165

fish-small-l
false
4
Circle -1184463 true true 209 150 44
Circle -1184463 true true 115 119 76
Polygon -2674135 true false 260 208 257 193 266 139 248 156 243 192 258 208
Circle -1184463 true true 143 116 68
Circle -1184463 true true 178 126 48
Circle -1184463 true true 177 156 48
Polygon -2674135 true false 160 121 168 113 177 105 203 107 196 121
Circle -1184463 true true 141 139 68
Polygon -2674135 true false 171 205 184 215 183 218 158 214 152 197
Polygon -1184463 true true 244 158 238 146 234 141 229 137 221 132 212 130 207 203 215 203 223 201 229 197 237 196
Circle -1 true false 132 133 21
Circle -16777216 true false 130 138 20
Polygon -16777216 true false 116 167 139 169 118 171

fish-small-r
false
4
Circle -1184463 true true 47 150 44
Circle -1184463 true true 109 119 76
Polygon -2674135 true false 40 208 43 193 34 139 52 156 57 192 42 208
Circle -1184463 true true 89 116 68
Circle -1184463 true true 74 126 48
Circle -1184463 true true 75 156 48
Polygon -2674135 true false 140 121 132 113 123 105 97 107 104 121
Circle -1184463 true true 91 139 68
Polygon -2674135 true false 129 205 116 215 117 218 142 214 148 197
Polygon -1184463 true true 56 158 62 146 66 141 71 137 79 132 88 130 93 203 85 203 77 201 71 197 63 196
Circle -1 true false 147 133 21
Circle -16777216 true false 150 138 20
Polygon -16777216 true false 184 167 161 169 182 171

five-pellets
false
14
Circle -16777216 true true 60 60 180
Polygon -16777216 true true 105 135 120 135 105 135
Polygon -7500403 true false 195 195
Polygon -13840069 true false 150 120
Polygon -16777216 true true 150 120 120 150 150 150 150 120
Polygon -7500403 true false 180 90
Polygon -13840069 true false 189 112 129 112 129 157 174 157 189 172 174 202 129 202 129 187 159 187 174 172 114 172 114 97 189 97

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

four-pellets
false
14
Circle -16777216 true true 60 60 180
Polygon -16777216 true true 105 135 120 135 105 135
Polygon -7500403 true false 195 195
Polygon -13840069 true false 105 150 150 90 165 90 165 150 180 150 180 165 165 165 165 210 150 210 150 165 90 165 120 135
Polygon -13840069 true false 150 120
Polygon -16777216 true true 150 120 120 150 150 150 150 120

gus
false
0
Polygon -7500403 true true 135 64 129 50 125 47 140 56 136 43 146 52 150 39 154 51 162 40 158 60
Polygon -7500403 true true 157 55 180 64 184 68 186 80 189 100 183 115 195 125 213 146 230 155 232 164 224 169 222 168 221 183 220 197 196 214 179 240 194 254 192 259 169 257 152 255 153 263 147 254 113 255 110 252 125 236 119 233 113 228 100 207 99 190
Polygon -7500403 true true 135 60 122 65 116 66 108 73 103 85 103 98 108 110 113 118 101 122 101 122 68 144 68 150 80 148 80 159 85 161 92 155 92 165 90 177 100 192 161 62 145 53
Circle -16777216 true false 114 75 18
Circle -1 true false 116 77 15
Circle -16777216 true false 146 72 24
Circle -1 true false 149 74 20
Circle -16777216 true false 119 80 6
Circle -16777216 true false 154 79 6
Circle -16777216 true false 142 188 6
Polygon -16777216 true false 169 228
Polygon -16777216 true false 221 168 213 161 219 170

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

laser-1
false
0
Circle -7500403 true true 54 54 192
Polygon -2674135 true false 105 135 124 116 148 101 161 101 182 101 205 111 198 113 198 113 197 123 197 131 215 132 206 143 177 155 162 206 150 211 119 210 101 197 95 187 111 145 106 138
Polygon -2064490 true false 196 110 221 115 213 135 195 132
Polygon -2064490 true false 171 178 139 178 124 209 160 208
Line -16777216 false 197 108 196 136
Line -16777216 false 171 179 139 178
Line -16777216 false 136 180 123 210
Line -16777216 false 145 181 145 208
Line -16777216 false 109 145 137 153
Polygon -1 true false 156 116 145 118 114 136 161 116
Line -16777216 false 197 134 211 137

laser-2
false
0
Circle -7500403 true true 54 54 192
Polygon -955883 true false 105 135 124 116 148 101 161 101 182 101 205 111 198 113 198 113 197 123 197 131 215 132 206 143 177 155 162 206 150 211 119 210 101 197 95 187 111 145 106 138
Polygon -2674135 true false 196 110 221 115 213 135 195 132
Polygon -2674135 true false 171 178 139 178 124 209 160 208
Line -16777216 false 197 108 196 136
Line -16777216 false 171 179 139 178
Line -16777216 false 136 180 123 210
Line -16777216 false 145 181 145 208
Line -16777216 false 109 145 137 153
Polygon -1 true false 156 116 145 118 114 136 161 116
Line -16777216 false 197 134 211 137

laser-3
false
0
Circle -7500403 true true 54 54 192
Polygon -10899396 true false 105 135 124 116 148 101 161 101 182 101 205 111 198 113 198 113 197 123 197 131 215 132 206 143 177 155 162 206 150 211 119 210 101 197 95 187 111 145 106 138
Polygon -13840069 true false 196 110 221 115 213 135 195 132
Polygon -13840069 true false 171 178 139 178 124 209 160 208
Line -16777216 false 197 108 196 136
Line -16777216 false 171 179 139 178
Line -16777216 false 136 180 123 210
Line -16777216 false 145 181 145 208
Line -16777216 false 109 145 137 153
Polygon -1 true false 156 116 145 118 114 136 161 116
Line -16777216 false 197 134 211 137

laser-4
false
0
Circle -7500403 true true 54 54 192
Polygon -16777216 true false 105 135 124 116 148 101 161 101 182 101 205 111 198 113 198 113 197 123 197 131 215 132 206 143 177 155 162 206 150 211 119 210 101 197 95 187 111 145 106 138
Polygon -1 true false 196 110 221 115 213 135 195 132
Polygon -1 true false 171 178 139 178 124 209 160 208
Line -16777216 false 197 108 196 136
Line -16777216 false 171 179 139 178
Line -16777216 false 136 180 123 210
Line -16777216 false 145 181 145 208
Line -16777216 false 109 145 137 153
Polygon -1 true false 156 116 145 118 114 136 161 116
Line -16777216 false 197 134 211 137
Polygon -1 true false 135 150 135 150
Polygon -1 true false 120 195 113 176 139 161 128 148 129 158 108 175 118 195

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

lion-boss-l
false
0
Polygon -2674135 true false 221 210 241 206 250 208 255 245 246 246 229 245 215 225
Polygon -16777216 true false 135 86 156 82 166 89 178 89 179 92 170 93 167 101 167 100 170 110 175 113 172 117 179 126 164 124 171 136 174 132 190 141 203 154 213 196 220 205 258 245 218 219 208 240
Polygon -2674135 true false 136 134 139 123 149 118 184 128 230 146 212 144 170 129 144 133
Polygon -2674135 true false 139 116 142 105 152 100 188 103 233 128 215 126 173 111 147 115
Polygon -2674135 true false 138 97 141 86 151 81 187 84 232 109 214 107 172 92 146 96
Polygon -16777216 true false 136 88 105 108 107 121 102 127 110 139 114 134 132 134 133 140 138 147 126 151 118 147 121 159 132 160 151 148 155 133
Polygon -955883 true false 134 89 155 85 165 92 177 92 178 95 169 96 166 104 166 103 169 113 174 116 171 120 178 129 163 127 170 139 173 135 189 144 202 157 212 199 219 208 259 247 217 222 201 243
Polygon -16777216 true false 205 248 205 259 199 251 195 238 184 243 190 217 177 211 160 212 145 207 136 219 135 229 133 239 124 235 133 204 129 199 135 194 135 158
Polygon -955883 true false 203 244 133 154 144 119 184 146
Polygon -2674135 true false 140 88 143 77 153 72 189 75 234 100 216 98 174 83 148 87
Polygon -955883 true false 202 240 205 260 194 256 192 250 184 252 192 214 179 208 162 209 147 204 138 216 137 226 135 236 126 232 135 201 131 196 137 191 137 155
Polygon -955883 true false 138 88 107 108 109 121 104 127 112 139 116 134 134 134 135 140 140 147 128 151 120 147 123 159 134 160 153 148 157 133
Polygon -5825686 true false 121 111 110 115 117 117 123 116 124 110
Line -6459832 false 148 203 138 195
Line -6459832 false 193 203 179 206
Line -6459832 false 180 207 168 194
Line -6459832 false 136 158 161 147
Line -6459832 false 146 155 166 170
Line -16777216 false 140 160 149 157
Line -16777216 false 149 157 159 149
Line -16777216 false 143 160 160 169
Line -16777216 false 160 169 163 192
Line -16777216 false 163 192 179 208
Line -6459832 false 215 221 211 206
Polygon -6459832 true false 214 219 204 235 202 245 202 241 216 223
Polygon -6459832 true false 150 159 167 170 168 193 179 207 165 192 161 168 145 160
Polygon -7500403 true true 135 207 147 203 162 208 176 207 163 193 159 170 142 161 137 161 137 190 133 194 135 200

lion-boss-r
false
0
Polygon -2674135 true false 79 210 59 206 50 208 45 245 54 246 71 245 85 225
Polygon -16777216 true false 165 86 144 82 134 89 122 89 121 92 130 93 133 101 133 100 130 110 125 113 128 117 121 126 136 124 129 136 126 132 110 141 97 154 87 196 80 205 42 245 82 219 92 240
Polygon -2674135 true false 164 134 161 123 151 118 116 128 70 146 88 144 130 129 156 133
Polygon -2674135 true false 161 116 158 105 148 100 112 103 67 128 85 126 127 111 153 115
Polygon -2674135 true false 162 97 159 86 149 81 113 84 68 109 86 107 128 92 154 96
Polygon -16777216 true false 164 88 195 108 193 121 198 127 190 139 186 134 168 134 167 140 162 147 174 151 182 147 179 159 168 160 149 148 145 133
Polygon -955883 true false 166 89 145 85 135 92 123 92 122 95 131 96 134 104 134 103 131 113 126 116 129 120 122 129 137 127 130 139 127 135 111 144 98 157 88 199 81 208 41 247 83 222 99 243
Polygon -16777216 true false 95 248 95 259 101 251 105 238 116 243 110 217 123 211 140 212 155 207 164 219 165 229 167 239 176 235 167 204 171 199 165 194 165 158
Polygon -955883 true false 97 244 167 154 156 119 116 146
Polygon -2674135 true false 160 88 157 77 147 72 111 75 66 100 84 98 126 83 152 87
Polygon -955883 true false 98 240 95 260 106 256 108 250 116 252 108 214 121 208 138 209 153 204 162 216 163 226 165 236 174 232 165 201 169 196 163 191 163 155
Polygon -955883 true false 162 88 193 108 191 121 196 127 188 139 184 134 166 134 165 140 160 147 172 151 180 147 177 159 166 160 147 148 143 133
Polygon -5825686 true false 179 111 190 115 183 117 177 116 176 110
Line -6459832 false 152 203 162 195
Line -6459832 false 107 203 121 206
Line -6459832 false 120 207 132 194
Line -6459832 false 164 158 139 147
Line -6459832 false 154 155 134 170
Line -16777216 false 160 160 151 157
Line -16777216 false 151 157 141 149
Line -16777216 false 157 160 140 169
Line -16777216 false 140 169 137 192
Line -16777216 false 137 192 121 208
Line -6459832 false 85 221 89 206
Polygon -6459832 true false 86 219 96 235 98 245 98 241 84 223
Polygon -6459832 true false 150 159 133 170 132 193 121 207 135 192 139 168 155 160
Polygon -7500403 true true 165 207 153 203 138 208 124 207 137 193 141 170 158 161 163 161 163 190 167 194 165 200

pellet
true
0
Circle -6459832 true false 116 116 67
Circle -6459832 true false 116 131 67
Circle -6459832 true false 116 146 67
Circle -6459832 true false 116 161 67

pellet-item1
false
0
Circle -7500403 true true 49 49 201
Circle -10899396 true false 129 105 42
Circle -10899396 true false 129 159 42
Rectangle -10899396 true false 130 123 169 183
Circle -16777216 true false 138 131 4
Circle -16777216 true false 156 152 4
Circle -16777216 true false 138 182 3
Circle -16777216 true false 139 161 6
Circle -16777216 true false 156 115 4
Circle -16777216 true false 161 181 4
Circle -16777216 true false 154 136 3

pellet-item2
false
0
Circle -7500403 true true 49 49 201
Circle -2674135 true false 129 105 42
Circle -1 true false 129 159 42
Rectangle -1 true false 129 151 171 183
Rectangle -2674135 true false 129 125 171 151

pellet2
false
0
Circle -10899396 true false 129 105 42
Circle -10899396 true false 129 159 42
Rectangle -10899396 true false 130 123 169 183
Circle -16777216 true false 138 131 4
Circle -16777216 true false 156 152 4
Circle -16777216 true false 138 182 3
Circle -16777216 true false 139 161 6
Circle -16777216 true false 156 115 4
Circle -16777216 true false 161 181 4
Circle -16777216 true false 154 136 3

pellet3
false
0
Circle -2674135 true false 129 105 42
Circle -1 true false 129 159 42
Rectangle -1 true false 129 151 171 183
Rectangle -2674135 true false 129 125 171 151

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

three-pellets
false
0
Circle -7500403 true true 60 60 180
Polygon -16777216 true false 105 135 120 135 105 135
Polygon -13840069 true false 105 135 150 90 195 135 150 165 195 180 195 195 135 165 150 150 180 135 150 105 120 135
Polygon -7500403 true true 195 195
Polygon -13840069 true false 195 195 120 210 120 195 180 180

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

two-pellets
false
0
Circle -7500403 true true 60 60 180
Polygon -16777216 true false 105 135 120 135 105 135
Polygon -13840069 true false 105 135 150 90 195 135 120 180 195 180 195 195 105 195 105 180 180 135 150 105 120 135

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0.4
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
