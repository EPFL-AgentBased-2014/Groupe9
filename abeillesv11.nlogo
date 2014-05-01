;Structre 
;Intrdouction/ interet de recherche
;Objectifs et hypothèses
;Methodes et prodedures
;Resultats
;Discussion et conclusion

breed [bees bee]
breed  [bugs bug]
turtles-own [energy] 
globals [rendement nbreannee gain gaintotal gainan-1 gainan-2 gainan-3 gainan-4]

;le bouton recolor a été desactivé !!!!!!!!!!! (edit pour reactiver)

to-report count-gain
  set gain (count (patches with [pcolor >= 62 and pcolor < 63 ]) * 100 ; cases très polénisées 
   + count (patches with [pcolor >= 63 and pcolor < 64 ]) * 80
   + count (patches with [pcolor >= 64 and pcolor < 65 ]) * 60
   + count (patches with [pcolor >= 65 and pcolor < 66 ]) * 40
   + count (patches with [pcolor >= 66 and pcolor < 67 ]) * 20 ; cases le moins polénisées
   ; les cases non polénisées ne rapportent rien
   + count (patches with [pcolor = 15 ]) * 50 ; cas des cases poison)
   )
  report gain
end

to count-rendement ; rendement au bout d'un certain nombre d'annee
  set nbreannee (nbreannee + 1)
  set gainan-4 gainan-3
  set gainan-3 gainan-2 
  set gainan-2 gainan-1
  set gainan-1 gain   
 ifelse (nbreannee >= 5) [ 
 set gaintotal (count-gain + gainan-1 + gainan-2 + gainan-3 + gainan-4)
  set rendement ( gaintotal ) / 5
  ] [ 
  set rendement count-gain 
  ]
  
end 

to print-rendement
  print rendement
end

to setup
  clear-all
  
  set-default-shape turtles "bee" ; change la forme des turtles en abeilles
  create-bees number-of-bees [setxy random-xcor random-ycor set size 0.9 set energy 3]
  layout-circle bees 1
  set-default-shape turtles "bug"
  create-bugs number-of-bees [setxy random-xcor random-ycor set size 0.9 set color 11]
  layout-circle bugs 20
   ask bugs [  ; les insectes sont sensible au poison au début
    if random 100 < poison-diffuse[
    die
    ]
   ]
   
  ask patches [
   set pcolor couleurbase
  ]
 
  reset-ticks ; compteur d'iterations a 0
end

to go
  tick
  move-bees
  move-bugs
  
if (ticks = Temps-d-une-annee) [ ; fait un reset partiel au bout d'une annee 
   count-rendement ;; calcul le rendement 
   update-and-plot-total
   update-and-plot-rendement
   ask patches [
    if not (pcolor = 15)[
      if not (pcolor = 67) [
        set pcolor couleurbase -(couleurbase - pcolor) * 0.5 ;; les champs reprennent leur état initial mais gardent un peu en memoire l'etat de l'année precedente
      ]
    ]
  ]
  clear-turtles ; supprime toutes les turtles
  set-default-shape turtles "bee" ; change la forme des turtles en abeilles
  create-bees number-of-bees [setxy random-xcor random-ycor set size 0.9 set energy 3]
  layout-circle bees 1
  set-default-shape turtles "bug"
  create-bugs number-of-bees [setxy random-xcor random-ycor set size 0.9 set color 11]
  layout-circle bugs 20
  ask bugs [  ; les insectes sont sensible au poison au début
    if random 100 < poison-diffuse[
    die
    ]
   ]
  reset-ticks
  ]
end

to update-and-plot-total ; modifie le graphe total value en affichant le gain à la fin d'une année
    set-current-plot "Gain total chaque année"
    plot count-gain
end

to update-and-plot-rendement ; modifie le graphe total value en affichant le gain à la fin d'une année
    count-rendement
    set-current-plot "rendement"
    ;if (ticks >= Temps-d-une-annee) [ 
    plot rendement 
    ;]
end


to move-bees ; bees procedure
  ask bees [
    right random 360
    forward 1
    if not(pcolor <= 62) [
      set pcolor  pcolor  - 3
    ]

    reproducebug
  ]
   life-bees
end

to life-bees ; bees procedure
   ask bees [
   if random-exponential (poison-diffuse * poison-diffuse ) < 10000 [
     set energy (energy - poison-diffuse * 0.005) 
   if energy <= 0[
     die 
    ]
   ]
  ]
  
  ask bees with [pcolor = 15] [
    if (energy - 1) <= 0[
      die
    ]
    set energy (energy - 1)
  ]
end

to move-bugs ; bugs procedure
  ask bugs [
    set heading towardsxy 0 0
    right random 180
    left random 180    
    forward 1 
    if not(pcolor >= 68) and (pcolor != 15) [ ; si un insecte marche sur une case qui n'est pas du poison 
       set pcolor  pcolor  + 1.2 ; il détériore le champs
    ]
    life-bug
    reproducebug
  ]
end

to life-bug ; bug procedure
  ask turtles with [pcolor = 15] [
    die 
  ]
end

to poison ; observer procedure poison ajouté à la main
    let edge 13
    let beg -13
        
       ask patches[
    ;; if patches are between (0,0) to (0,edge)...
    if ( pxcor = beg and pycor >= beg and pycor <= edge )
      [set pcolor 15]                                 ;; ... draws left edge in red
    ;; if patches are between (edge,0) to (edge,edge)...
    if ( pxcor = edge and pycor >= beg and pycor <= edge )
      [set pcolor 15]                                 ;; ... draws right edge in red
    ;; if patches are between (0,0) to (edge,0)...
    if ( pycor = beg and pxcor >= beg and pxcor <= edge )
      [set pcolor 15]                                 ;; ... draws bottom edge in red
    ;; if patches are between (0,edge) to (edge,edge)...
    if ( pycor = edge and pxcor >= beg and pxcor <= edge )
      [set pcolor 15]                                 ;; ... draws upper edge in red
    ]
       
end
   
   ;while [mouse-down?] [ask patch mouse-xcor mouse-ycor [
    ;  ifelse (pcolor != 15) [
     ;   set pcolor 15 
      ;  ][  
       ; set pcolor 67
        ;]
      ;] 
    ;wait 0.1
    ;display 
    ;]
;end


to reproducebug  ; turtle procedure; dans une année complète les abeilles/insectes peuvent se reproduire un peu
  if random-float 1000 < bug-reproduce [  ; 
    hatch 1 [ rt random-float 360]  ;
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
235
15
709
510
20
20
11.33333333333334
1
10
1
1
1
0
1
1
1
-20
20
-20
20
0
0
1
ticks
30.0

BUTTON
17
20
81
53
Setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

INPUTBOX
928
493
1083
553
couleurbase
67
1
0
Color

BUTTON
90
66
153
99
Go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
17
66
80
99
Go
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
15
128
214
161
Temps-d-une-annee
Temps-d-une-annee
0
50
33
1
1
mois
HORIZONTAL

SLIDER
15
168
214
201
number-of-bees
number-of-bees
0
500
180
10
1
NIL
HORIZONTAL

BUTTON
13
333
80
366
Poison
poison
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
91
333
241
389
Vous pouvez liberer du poison sur une case qui tuera les insectes et qui fera mal aux abeilles. \n
11
0.0
1

SLIDER
15
208
214
241
bug-reproduce
bug-reproduce
0
10
1
1
1
NIL
HORIZONTAL

TEXTBOX
153
241
220
274
x pour 1000
11
0.0
1

MONITOR
763
21
823
66
Bees
count bees
17
1
11

PLOT
830
21
1083
141
Nombre abeilles et insectes
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Abeilles" 1.0 0 -1184463 true "" "plot count bees"
"Insectes" 1.0 0 -955883 true "" "plot count bugs"

PLOT
772
175
1133
321
Gain total chaque année
NIL
NIL
0.0
10.0
25000.0
75000.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" ""

PLOT
773
330
1133
480
Rendement
NIL
NIL
0.0
10.0
25000.0
75000.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" ";plot rendement"

MONITOR
764
78
824
123
Insectes
count bugs
17
1
11

SLIDER
24
282
223
315
Poison-diffuse
Poison-diffuse
0
100
0
1
1
NIL
HORIZONTAL

BUTTON
6
372
90
406
Reset poison
ask patches with [pcolor = 15] [set pcolor 67]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
9
421
98
466
Red patches
count patches with [pcolor = 15]
17
1
11

@#$#@#$#@
## WHAT IS IT? Qu'est ce que ce modèle ?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS Comment fonctionne-t-il ?

(what rules the agents use to create the overall behavior of the model)
 
## HOW TO USE IT Comment l'utiliser ?

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE Qu'est ce qu'observer ?

(suggested things for the user to notice while running the model)

## THINGS TO TRY A essayer

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL Comment pourrait-on modifier, completer le modèle ?

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS Modèles liés

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

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

bee
true
0
Polygon -1184463 true false 152 149 77 163 67 195 67 211 74 234 85 252 100 264 116 276 134 286 151 300 167 285 182 278 206 260 220 242 226 218 226 195 222 166
Polygon -16777216 true false 150 149 128 151 114 151 98 145 80 122 80 103 81 83 95 67 117 58 141 54 151 53 177 55 195 66 207 82 211 94 211 116 204 139 189 149 171 152
Polygon -7500403 true true 151 54 119 59 96 60 81 50 78 39 87 25 103 18 115 23 121 13 150 1 180 14 189 23 197 17 210 19 222 30 222 44 212 57 192 58
Polygon -16777216 true false 70 185 74 171 223 172 224 186
Polygon -16777216 true false 67 211 71 226 224 226 225 211 67 211
Polygon -16777216 true false 91 257 106 269 195 269 211 255
Line -1 false 144 100 70 87
Line -1 false 70 87 45 87
Line -1 false 45 86 26 97
Line -1 false 26 96 22 115
Line -1 false 22 115 25 130
Line -1 false 26 131 37 141
Line -1 false 37 141 55 144
Line -1 false 55 143 143 101
Line -1 false 141 100 227 138
Line -1 false 227 138 241 137
Line -1 false 241 137 249 129
Line -1 false 249 129 254 110
Line -1 false 253 108 248 97
Line -1 false 249 95 235 82
Line -1 false 235 82 144 100

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

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

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

dot
false
0
Circle -7500403 true true 90 90 120

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

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

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

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

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
NetLogo 5.0.5
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="experiment" repetitions="200" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="100"/>
    <metric>count bees</metric>
    <metric>count bugs</metric>
    <metric>report rendement</metric>
    <steppedValueSet variable="bug-reproduce" first="5" step="1" last="9"/>
    <enumeratedValueSet variable="Temps-d-une-annee">
      <value value="48"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-bees">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="couleurbase">
      <value value="67"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
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
