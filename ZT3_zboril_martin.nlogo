breed [randomAgents randA] ; agent Motýl - náhodný pohyb
breed [determinedAgents detA] ;  agent Člověk - deterministický pohyb
breed [lineAgents linA] ; agent Vlk - nejprve náhodný, poté deterministický pohyb

globals
[
  tmp ; pomocna promena u determinedAgents pro to, jestli se agent bude otacet vlevo nebo vpravo
  tmp2 ; pomocna promena u determinedAgents pro to, jestli se agent bude otacet vlevo nebo vpravo
  amountA ; pocet kroku - determinedAgents
  amountR ; pocet kroku - randomAgents
  amountL ; pocet kroku - lineAgents
  doneR ; jestlize, randomAgents vstoupi na zelene policko, tak se nastavi na 1 a tim cely program skonci
  boolCachedLine ; pomocny boolean pro lineAgents, zaznamenava, jestli tento agent uz narazil na stopu determinedAgents
  boolWrongEnd ; pomocny boolean pro lineAgents, zaznamenava, jestli tento agent narazil na spatny konec (pocatecni misto) stopy determinedAgents
]
  
to setup
  clear-all
  setup-patches
  setup-turtles
  reset-ticks
end

to setup-turtles
  set-default-shape lineAgents "wolf"
  set-default-shape randomAgents "butterfly"
  set-default-shape determinedAgents "person"
  set doneR 0
  if AgentRandom
    [create-randomAgents 1 
    ask randomAgents [ setxy X_cor-AgentRandom Y_cor-AgentRandom ] ; nastavi agenta na pozici
    ask randomAgents [ set heading 0 ] ; nastavi mu aby se koukal nahoru
    ask randomAgents [ set size 10 ] ; nastavi velilkost 
    ask randomAgents [ pen-up ] ; zvednutí pera
    set AmountR 0] ; počet kroků je na začátku 0
  
  if AgentAlgorithm
    [create-determinedAgents 1 
    ask determinedAgents [ setxy X_cor-AgentAlgorithm Y_cor-AgentAlgorithm ] ; nastavi agenta na pozici
    ask determinedAgents[ set heading 0 ] ; nastavi mu aby se koukal nahoru
    ask determinedAgents[ set size 10 ] ; nastavi velilkost 
    ask determinedAgents [ pen-up ] ; zvednutí pera
    set amountA 0] ; počet kroků je na začátku 0
     
  
  
  if AgentLine
    [create-lineAgents 1 
    ask lineAgents [ setxy X_cor-AgentLine Y_cor-AgentLine ] ; nastavi agenta na pozici
    ask lineAgents[ set heading 0 ] ; nastavi mu aby se koukal nahoru
    ask lineAgents[ set size 10 ] ; nastavi velilkost 
    ask lineAgents [ pen-up ] ; zvednutí pera
    set amountL 0 ; počet kroků je na začátku 0
    set boolWrongEnd 0 
    set boolCachedLine 0] 
end

to go 
  if doneR = 1 [ stop ]        
  move-agent-random
  move-agent-algorithm  
  move-agent-line
  tick     
end

to move-agent-line
  ask lineAgents[
    if pcolor = green [stop]   ; jestli najede na zelenou barvu, tak skonci 
    if [pcolor] of patch-ahead 1 = green [set pcolor grey] ; na predposlednim policku zmeni barvu, aby se agent uz nevracel
    ifelse (pcolor = blue or pcolor = 104); jestli ze najede na modrou
        [set boolCachedLine 1 ; nastavi se, ze se narazilo na modrou caru
        if (count neighbors4 with [pcolor = blue] = 1 and count neighbors4 with [pcolor = green] = 0 and boolCachedLine = 1)[set boolWrongEnd 1] ; pokud se dojelo na spatny konec ...
        ; ... modry cary, tak se nastavi boolWrongEnd na 1
        while [[pcolor] of patch-ahead 1 != blue and count neighbors4 with [pcolor = blue] >= 1] ; jestli dalsi policko neni modry a zaroven nejake modre policko v okoli je...
            [ ifelse random 2 mod 2 = 0 [rt 90] [lt 90]]  ; ... otaci se do te doby, nez bude modry       
       if boolWrongEnd = 1 [set pcolor 104] ; jestlize se jiz narazilo na spatny konec cary, tak se policko obarvi na jinou modrou 
        ]         
        ; jestlize neni modry dalsi policko a neni v okoli zadne
    [ ifelse [pcolor] of patch-ahead 1 = black ; zkontroluje se, jestli je dalsi cerny
        [lt 180] ; jestli ano, tak se otoci zpet
        [ifelse tmp2 mod 99 = 0 [lt 90][if tmp2 mod 99 = 1 [rt 90]]] ; jestli ne, tak se otoc v malem procentu pripadu doleva nebo doprava
      set pcolor grey ; pokud se volne pohybuje v poli, tak za sebou zanechava sedivou caru
    ]

    fd 1 ; vzdy se postoupi o krok 
    set amountL amountL + 1
  ]
  
end 

to move-agent-random
  ask randomAgents[    
    if pcolor = green  ; jestlize najede na zeleny pole 
        [set  doneR 1 ; tak se nastavi pomocna promena na 1
        stop]  ; zastavi se agent
    
    if pcolor != blue and pcolor != 104
        [ask randomAgents [set pcolor red ]] ; jestlize nestoji na modrym policku (i 104 barve) tak se prebarvi na cerveny
        
    ifelse [pcolor] of patch-ahead 1 = black ; jestlize je nasledujici policko cerne
        [lt 180] ; tak se agent otoci
        ; jestlize neni cerne, tak se zkontroluje, jestli je na stranach agenta a pred agentem cerne policko
        [if (any? patches in-cone 9 90 with [pcolor = black]) and (any? patches in-cone 9 270 with [pcolor = black]) and (any? patches in-cone 20 0 with [pcolor = black]) 
           [ if [pcolor] of patch-ahead 1 != black  
             [fd 1 ;posune se o jedno
             set amountR amountR + 1] 
            ifelse random 233 mod 2 = 0 [lt 90] [rt 90]] ; a otoci se doleva
        
         set tmp2 random RandomNumber ; nastaveni pomocne promenne
         ifelse tmp2 mod Modulo = 0 
            [lt 90] ; v nahodnych opakovani se agent otoci doleva
            [ifelse tmp2 mod Modulo != 1                  
                [if [pcolor] of patch-ahead 1 != black  
                  [fd 1
                  set amountR amountR + 1]; ve vetsine pripadu se popojde o jeden krok
                 ]     
            [rt 90]]     ; v dalsich nahodnych opakovi se otoci doprava
      ]     
    ]
end

to move-agent-algorithm
    ask determinedAgents[
      if pcolor = green [stop] ; pokud je na zelenym, tak se zastavi    
      ask determinedAgents [ set pcolor blue ] ; nastaveni policko na modrou barvu
      ifelse [pcolor] of patch-ahead 1 = black ; pokud je pred agentem cerna barva 
        [ifelse tmp = 0 ; jestli se bude otacek vlevo nebo vparvo
            [lt 90] 
            [rt 90] 
         ifelse [pcolor] of patch-ahead 1 = black ; pokud je znova cerna 
            [ifelse tmp = 0 [lt 90] [rt 90]] ;jeste jednou otocit
            [fd 1 ;pokud neni druha cerna barva tak jit dopredu    
             set amountA amountA + 1] ;zvys pocet kroku o jeden
        ifelse tmp = 0  ; jestli se bude otacek vlevo nebo vparvo
            [rt 90]  ; 
            [lt 90]  ; natocit se smerek k care           
        ]
        ;pokud pred agentem neni cerna barva
        [fd 1 ; jdi o policko vpred
        set amountA amountA + 1 ; zvys pocet kroku o jedna
        ifelse (amountR * amountL * (random 99999999)) mod 2 = 1 [set tmp 1] [set tmp 0] ; nahodne rozhoduje jestli se bude otaacek vlevo nebo vpravo priste
      ]      
  ]
    
end

; bludiste
to setup-patches
  ask patches [ set pcolor yellow]
    
  ; first layer
  if NumberOfLayers >= 1[
    ask patches with [pycor = 10 and pxcor <= 50 and pxcor >= -50 ][ set pcolor black ] ; nahore
    ask patches with [pxcor = -50 and pycor <= 10 and pycor >= -30 ][ set pcolor black ] ; vlevo
    ask patches with [pycor = -30 and pxcor <= 50 and pxcor >= 5 ][ set pcolor black ]  ; dole mezera
    ask patches with [pycor = -30 and pxcor <= -20 and pxcor >= -50 ][ set pcolor black ]  ; dole mezera
    ask patches with [pxcor = 50 and pycor <= 10 and pycor >= -30 ][ set pcolor black ] ; vpravo]
  ]

  ;second layer
  if NumberOfLayers >= 2[
    ask patches with [pycor = 20 and pxcor <= 70 and pxcor >= 50 ][ set pcolor black ] ; nahore mezera
    ask patches with [pycor = 20 and pxcor <= 20 and pxcor >= -70 ][ set pcolor black ] ; nahore mezera
    ask patches with [pxcor = -70 and pycor <= 20 and pycor >= -45 ][ set pcolor black ] ; vlevo
    ask patches with [pycor = -45 and pxcor <= 70 and pxcor >= -70 ][ set pcolor black ]  ; dole 
    ask patches with [pxcor = 70 and pycor <= 20 and pycor >= -45 ][ set pcolor black ] ; vpravo   
  ]
    
  ;third layer
  if NumberOfLayers >= 3[
    ask patches with [pycor = 30 and pxcor <= 90 and pxcor >= -90 ][ set pcolor black ] ; nahore
    ask patches with [pxcor = -90 and pycor <= 30 and pycor >= -15 ][ set pcolor black ] ; vlevo mezera
    ask patches with [pxcor = -90 and pycor <= -45 and pycor >= -60 ][ set pcolor black ] ; vlevo mezera
    ask patches with [pycor = -60 and pxcor <= 90 and pxcor >= -90 ][ set pcolor black ]  ; dole 
    ask patches with [pxcor = 90 and pycor <= 30 and pycor >= -60][ set pcolor black ] ; vpravo
  ]
  
  ;fourth layer
  if NumberOfLayers >= 4[
    ask patches with [pycor = 40 and pxcor <= 110 and pxcor >= -110 ][ set pcolor black ] ; nahore
ask patches with [pxcor = -110 and pycor <= 40 and pycor >= -75 ][ set pcolor black ] ; vlevo mezera
    ask patches with [pycor = -75 and pxcor <= 110 and pxcor >= -110 ][ set pcolor black ]  ; dole 
    ask patches with [pxcor = 110 and pycor <= 40 and pycor >= 20 ][ set pcolor black ] ; vpravo mezera
    ask patches with [pxcor = 110 and pycor <= -10 and pycor >= -75 ][ set pcolor black ] ; vpravo mezera
  ]
  ; fifth layer
  if NumberOfLayers >= 5[
    ask patches with [pycor = 60 and pxcor <= 130 and pxcor >= -130 ][ set pcolor black ] ; nahore
    ask patches with [pxcor = -130 and pycor <= 60 and pycor >= -90 ][ set pcolor black ] ; vlevo
    ask patches with [pycor = -90 and pxcor <= 130 and pxcor >= 30 ][ set pcolor black ]  ; dole mezera
    ask patches with [pycor = -90 and pxcor <= 0 and pxcor >= -130 ][ set pcolor black ]  ; dole mezera
    ask patches with [pxcor = 130 and pycor <= 60 and pycor >= -90 ][ set pcolor black ] ; vpravo
  ]
       
  ;sixth layer
  if NumberOfLayers >= 6[
    ask patches with [pycor = 80 and pxcor <= 160 and pxcor >= -125 ][ set pcolor black ] ; nahore mezera
    ask patches with [pycor = 80 and pxcor <= -155 and pxcor >= -160 ][ set pcolor black ] ; nahore mezera
    ask patches with [pxcor = -160 and pycor <= 80 and pycor >= -105 ][ set pcolor black ] ; vlevo
    ask patches with [pycor = -105 and pxcor <= 160 and pxcor >= -160 ][ set pcolor black ]  ; dole 
    ask patches with [pxcor = 160 and pycor <= 80 and pycor >= -105 ][ set pcolor black ] ; vpravo
  ]
 
  ;seventh layer
  if NumberOfLayers >= 7[
    ask patches with [pycor = 100 and pxcor <= 180 and pxcor >= -180 ][ set pcolor black ] ; nahore
    ask patches with [pxcor = -180 and pycor <= 100 and pycor >= -20 ][ set pcolor black ] ; vlevo mezera
    ask patches with [pxcor = -180 and pycor <= -50 and pycor >= -120 ][ set pcolor black ] ; vlevo mezera
    ask patches with [pycor = -120 and pxcor <= 180 and pxcor >= -180 ][ set pcolor black ]  ; dole 
    ask patches with [pxcor = 180 and pycor <= 100 and pycor >= -120 ][ set pcolor black ] ; vpravo
  ]
  
  ;eighth layer
  if NumberOfLayers >= 8[
    ask patches with [pycor = 120 and pxcor <= 210 and pxcor >= -210 ][ set pcolor black ] ; nahore
    ask patches with [pxcor = -210 and pycor <= 120 and pycor >= -135 ][ set pcolor black ] ; vlevo mezera
    ask patches with [pycor = -135 and pxcor <= 210 and pxcor >= -210][ set pcolor black ]  ; dole 
    ask patches with [pxcor = 210 and pycor <= 120 and pycor >= 30 ][ set pcolor black ] ; vpravo mezera
    ask patches with [pxcor = 210 and pycor <= 0 and pycor >= -135 ][ set pcolor black ] ; vpravo mezera
  ]
  
  ;cil
  ask patches with [pycor > 138 and pycor <= 150  and pxcor <= 250 and pxcor >= -250 ][ set pcolor green ] ; zeleny nahore
  ask patches with [pycor >= -150 and pycor <= -140  and pxcor <= 250 and pxcor >= -250 ][ set pcolor green ] ; zeleny dole
  ask patches with [pycor > -150 and pycor <= 150  and pxcor <= -230 and pxcor >= -250 ][ set pcolor green ] ; zeleny vlevo
  ask patches with [pycor > -150 and pycor <= 150  and pxcor <= 250 and pxcor >= 230 ][ set pcolor green ] ; zeleny vpravo
end
@#$#@#$#@
GRAPHICS-WINDOW
224
20
1236
653
250
150
2.0
1
10
1
1
1
0
1
1
1
-250
250
-150
150
0
0
1
ticks
30.0

BUTTON
148
20
222
53
Setup
setup\n
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
149
58
223
91
Go
go
T
1
T
OBSERVER
NIL
G
NIL
NIL
1

BUTTON
150
97
222
130
GoStep
go
NIL
1
T
OBSERVER
NIL
H
NIL
NIL
1

SWITCH
2
20
145
53
AgentAlgorithm
AgentAlgorithm
0
1
-1000

SWITCH
3
96
146
129
AgentRandom
AgentRandom
0
1
-1000

CHOOSER
4
134
146
179
NumberOfLayers
NumberOfLayers
1 2 3 4 5 6 7 8
5

SLIDER
15
343
205
376
X_cor-AgentAlgorithm
X_cor-AgentAlgorithm
-200
200
-15
1
1
NIL
HORIZONTAL

SLIDER
14
382
205
415
Y_cor-AgentAlgorithm
Y_cor-AgentAlgorithm
-120
120
-15
1
1
NIL
HORIZONTAL

SLIDER
16
500
205
533
X_cor-AgentRandom
X_cor-AgentRandom
-200
200
0
1
1
NIL
HORIZONTAL

SLIDER
17
541
207
574
Y_cor-AgentRandom
Y_cor-AgentRandom
-120
120
-15
1
1
NIL
HORIZONTAL

MONITOR
4
186
219
231
Amount Steps - Agent Algorithm
amountA
17
1
11

MONITOR
5
288
220
333
Amount Steps R
amountR
17
1
11

SWITCH
3
58
145
91
AgentLine
AgentLine
0
1
-1000

MONITOR
4
237
220
282
Amount Steps - Agent Keep Line
amountL
17
1
11

SLIDER
15
423
205
456
X_cor-AgentLine
X_cor-AgentLine
-200
200
15
1
1
NIL
HORIZONTAL

SLIDER
15
461
205
494
Y_cor-AgentLine
Y_cor-AgentLine
-120
120
-15
1
1
NIL
HORIZONTAL

SLIDER
18
600
190
633
RandomNumber
RandomNumber
10
2000
215
5
1
NIL
HORIZONTAL

SLIDER
19
643
191
676
Modulo
Modulo
10
500
35
1
1
NIL
HORIZONTAL

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

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

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
NetLogo 5.2.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="Experiment-NotChangingStartPoint" repetitions="10" runMetricsEveryStep="false">
    <setup>setup
set NumberOfLayers ((random 7) + 1)</setup>
    <go>go</go>
    <exitCondition>doneR = 1</exitCondition>
    <metric>amountA</metric>
    <metric>amountR</metric>
    <metric>amountL</metric>
    <enumeratedValueSet variable="RandomNumber">
      <value value="215"/>
    </enumeratedValueSet>
    <steppedValueSet variable="NumberOfLayers" first="1" step="1" last="8"/>
    <enumeratedValueSet variable="Modulo">
      <value value="35"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment_same_value" repetitions="40" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>doneR = 1</exitCondition>
    <metric>amountA</metric>
    <metric>amountR</metric>
    <metric>amountL</metric>
    <enumeratedValueSet variable="RandomNumber">
      <value value="215"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Modulo">
      <value value="35"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="NumberOfLayers">
      <value value="6"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment_raising_modulo" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>doneR = 1</exitCondition>
    <metric>amountA</metric>
    <metric>amountR</metric>
    <metric>amountL</metric>
    <enumeratedValueSet variable="RandomNumber">
      <value value="1000"/>
    </enumeratedValueSet>
    <steppedValueSet variable="Modulo" first="20" step="11" last="999"/>
    <enumeratedValueSet variable="NumberOfLayers">
      <value value="6"/>
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
