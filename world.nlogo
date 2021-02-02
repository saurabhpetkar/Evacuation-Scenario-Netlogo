globals
[
  people-reached-safe-zone
  people-killed-by-terrorists
  people-killed-by-stampede
  exit-1-xcor
  exit-1-ycor
  exit-2-xcor
  exit-2-ycor
  exit-3-xcor
  exit-3-ycor
  exit-4-xcor
  exit-4-ycor
  exit-node
  group_count
  queue
  ;;............ for verification
]


patches-own
[
  p_type
  dist
]

breed [civilians civilian]
breed [terrorists terrorist]
breed [rescuers rescuer]

civilians-own
[
  initial-blood
  know-exit
  vision-distance
  vision-angle           ; custom civilian attributes
  journey_list
  direction_moved
  group_no
  leader?

]

rescuers-own
[
  vision-distance
  vision-angle
]

terrorists-own
[
  initial-blood
  vision-distance      ; custom terrorist attributes
  vision-angle
]
;; ---------------- Setup --------------------------------------------
to bfs
  let s length queue
  let patch-count 0
  while [s > 0] [
    let i 0
    while [i < s][
      ;;first patch
      let curr first queue
      let curr-dist [dist] of curr
      ask curr [
        ask neighbors4 with [pcolor = white and dist < 0][ set dist curr-dist + 1 set queue lput self queue set patch-count patch-count + 1]
      ]


      ;;pop first
      set queue but-first queue

      set i i + 1
    ]
    set s length queue
  ]
  ;print "bfs calculated for total patches: "
  ;print patch-count
end

;; --------------------- Cumulative Setup -----------------------------------
to setup

  clear-all
  set queue []

  setup-world
  setup-exits
  setup-signs
  setup-civilians
  setup-coordinates
  bfs

  if setup-choices = 1 [ setup-terrorists-1]
  if setup-choices = 2 [ setup-terrorists-2]
  if setup-choices = 3 [ setup-terrorists-3]

  set group_count 0
  setup-group
  setup-rescuers

  reset-ticks
end
;; --------------------- Civilian Setup ------------------------------------------------------------
to setup-civilians

  ask n-of civilians-count  (patches with [pcolor = white and pxcor > 25 and pxcor < 141 and pycor > 5 and pycor < 95 ]  ) [sprout-civilians 1]
  ask civilians
  [
    set shape "dot"
    set color cyan - 1
    set initial-blood random-normal civilian-blood-mean civilian-blood-sd
    set size 2
    if initial-blood < 86[
      set color cyan + 2
    ]

    ifelse random 100 < Percentage-know-exits
    [
      set know-exit true
      set color magenta
    ]
    [ set know-exit false]

    set vision-distance civilian-vision-distance
    set vision-angle civilian-vision-angle
    set journey_list []
    set direction_moved 0
    set leader? false
    set group_no 0

  ]

end

to setup-group
  ask civilians
  [
    if random 1000 < 5
    [
      set group_count group_count + 1
      set group_no group_count
      set leader? true
      set color orange

      let no-of-civilian_buddies count civilians in-radius 4

      let no-of-people min list no-of-civilian_buddies  4

      ask n-of no-of-people civilians in-radius 4
      [
        set group_no group_count
        set color orange
      ]
    ]
  ]

end

;; ------------------------------- Terrorist Setup ----------------------------------------------------------------

to setup-terrorists-1

  ask n-of terrorists-count  (patches with [ pcolor = white and pxcor > 25 and pxcor < 141 and pycor > 5 and pycor < 95 ]) [sprout-terrorists 1]
  ask terrorists
  [
    set color red
    set shape "person"
    set size 3
    set initial-blood terrorist-blood
    set vision-distance terrorists-vision-dist
    set vision-angle terrorists-vision-angle
 ]

end

to setup-terrorists-2

  ask n-of terrorists-count  (patches with [pcolor = white and pxcor > 25 and pxcor < 141 and pycor > 5 and pycor < 95 ]) [sprout-terrorists 1]
  ask terrorists
  [
    set color red
    set shape "person"
    set size 3
    set initial-blood terrorist-blood

    set vision-distance terrorists-vision-dist
    set vision-angle terrorists-vision-angle
    ;set pxcor

    let pos random 4

    if pos = 0
    [
       set xcor exit-1-xcor + random 2
       set ycor exit-1-ycor + random 2
    ]

    if pos = 1
    [
       set xcor exit-2-xcor + random 2
       set ycor exit-2-ycor + random 2
    ]

    if pos = 2
    [
       set xcor exit-3-xcor + random 2
       set ycor exit-3-ycor + random 2
    ]

    if pos = 3
    [
       set xcor exit-4-xcor + random 2
       set ycor exit-4-ycor + random 2
    ]


  ]


end

to setup-terrorists-3

  ask n-of terrorists-count  (patches with [pcolor = white and pxcor > 25 and pxcor < 141 and pycor > 5 and pycor < 95 ]) [sprout-terrorists 1]
  ask terrorists
  [
    set color red
    set shape "person"
    set size 3
    set initial-blood terrorist-blood
    set vision-distance terrorists-vision-dist
    set vision-angle terrorists-vision-angle
  ]
  layout-circle terrorists 9

end
;; ---------------------------- Rescuer Setup -----------------------------------------------------------------------
to setup-rescuers

  ask n-of rescue-count  (patches with [pcolor = white and pxcor > 25 and pxcor < 141 and pycor > 5 and pycor < 95 ]) [sprout-rescuers 1]
  ask rescuers
  [
    set color brown
    set size 3
    set vision-distance rescue-vision-distance
    set vision-angle rescue-vision-angle
  ]
end
;; ----------------------------- Setup Environment  ---------------------------------------------------------------------------------------
to setup-coordinates
  set exit-1-xcor 137
  set exit-1-ycor 71

  set exit-2-xcor 22
  set exit-2-ycor 94

  set exit-3-xcor 35
  set exit-3-ycor 93

  set exit-4-xcor 137
  set exit-4-ycor 30

  set people-reached-safe-zone 0
  set people-killed-by-terrorists 0
  set people-killed-by-stampede 0
end



to setup-world

  import-pcolors "Mall_2.png"
  ask patches with [pcolor >= 0 and pcolor <= 9.2 ]
  [
    set pcolor black
    set p_type "walls"
  ]
  ask patches with [pcolor != black ] [ set pcolor white ]
  ask patches with [pcolor = black or pcolor = yellow ] [ set dist 100000 ]

end

to setup-exits
  ask patches [
     if pcolor = white [
      set dist -1
    ]
    if pxcor = 18 and pycor >= 90  and pycor <= 97 [set pcolor green set p_type "safe" set dist 0 set queue lput self queue]
    if pxcor >= 30 and pxcor <= 42 and pycor = 100 [set pcolor green set p_type "safe" set dist 0 set queue lput self queue]
    if pxcor = 143 and pycor >= 66 and pycor <= 76 [set pcolor green set p_type "safe" set dist 0 set queue lput self queue]
    if pxcor = 143 and pycor >= 28 and pycor <= 32 [set pcolor green set p_type "safe" set dist 0 set queue lput self queue]
  ]
end

to setup-signs
  if exit-signs[
    ask patches[
      if pxcor = 41 and pycor >= 30 and pycor <= 33 [set pcolor yellow set p_type "sign"]
      if pxcor = 28 and pycor >= 66 and pycor <= 69 [set pcolor yellow set p_type "sign"]
      if pxcor >= 98 and pxcor <= 100 and pycor = 79 [set pcolor yellow set p_type "sign"]
      if pxcor >= 52 and pxcor <= 55 and pycor = 51 [set pcolor yellow set p_type "sign"]
      if pxcor >= 93 and pxcor <= 95 and pycor = 44 [set pcolor yellow set p_type "sign"]
      if pxcor = 119 and pycor >= 28 and pycor <= 31 [set pcolor yellow set p_type "sign"]
      if pxcor = 127 and pycor >= 56 and pycor <= 59 [set pcolor yellow set p_type "sign"]
      if pxcor >= 90  and pxcor <= 93 and pycor = 16 [set pcolor yellow set p_type "sign"]
      if pxcor >= 329  and pxcor <= 339 and pycor >= 61 and pycor <= 62 [set pcolor   yellow set p_type "sign"]
    ]
  ]
end

;; ----------------- go --------------------------------------------
to go

  if count civilians = 0 or count terrorists = 0
  [
    stop
  ]

  ask civilians
  [
   ;civilian-movement
   ;check-stampede
   ;check-death
   ;reached-safe-zone
   ;follow-signs
    know-path
  ]

  ask terrorists
  [
    terrorists-movement
  ]

  ask rescuers
  [
    rescue-movement
  ]

  tick
end

;; ---------------------- Rescuer Methods --------------------------------------------

to wiggle  ;; turtle procedure
  rt random 40
  lt random 40

end
to rescue-movement

  ask civilians-on patches in-cone vision-distance vision-angle
  [
    set know-exit  true
    set color magenta
  ]

  let close-wall one-of neighbors with [ pcolor = yellow or pcolor = black ] in-radius 1
  ifelse close-wall != nobody
  [
    face close-wall
    rt 180
    fd 1
  ]
  [
    wiggle
    fd 1
  ]
  kill-terrorists
end


to kill-terrorists

  let target-terrorist one-of terrorists-on patches in-cone vision-distance vision-angle
  ifelse target-terrorist != nobody and remainder ticks 3 = 0
  [
    let distance_bw [ distance target-terrorist ] of patch-here
    let inbw patches in-cone distance_bw 1
    let wall_patches one-of inbw with [ pcolor != white ]

    ifelse wall_patches = nobody
    [
      move-to terrorist [who] of target-terrorist
      ifelse random 100 < 60
      [ ask target-terrorist [die] ]
      [ die ]
    ]
    [
      face wall_patches
      rt 180
      fd 1
    ]
  ]
  [
    let close-wall one-of neighbors with [ pcolor != white ] in-radius 3
    ifelse close-wall != nobody
    [
      face close-wall
      rt 180
    ]
    [
      wiggle
    ]
    fd 1
  ]

end

;; ------------------- terrorist methods -------------------------------------------------

to terrorists-movement

  let target-civilian one-of civilians-on patches in-cone vision-distance vision-angle
  ifelse target-civilian != nobody and remainder ticks 3 = 0
  [
    let distance_bw [ distance target-civilian ] of patch-here
    let inbw patches in-cone distance_bw 17

    let wall_patches one-of inbw with [ pcolor != white ]

    ifelse wall_patches = nobody
    [
      move-to civilian [who] of target-civilian
      set people-killed-by-terrorists people-killed-by-terrorists + 1
      ask target-civilian [die]
    ]
    [
      face wall_patches
      rt 180
      fd 1
    ]
  ]
  [
    let close-wall one-of neighbors with [ pcolor != white ] in-radius 3
    ifelse close-wall != nobody
    [
      face close-wall
      rt 180
    ]
    [
      rt random 360
    ]
    fd 1
  ]

end


;; ------------------- Civilian methods -------------------------------------------------

to civilian-movement

  let target-patch min-one-of (patches with [pcolor = green]) [distance myself]
  set journey_list fput (list int who int xcor int ycor) journey_list

  let close-wall one-of neighbors with [ pcolor = yellow or pcolor = black ] in-radius 3
  let exit-patch one-of neighbors with [ pcolor = green ] in-radius 3
  let neighbour-terrorists terrorists-on patches in-cone vision-distance vision-angle
  direction-movement

  ifelse any? neighbour-terrorists
  [
    ifelse group_no = 0 or (group_no > 0 and leader? = true)
    [
      if close-wall = nobody
      [
        let target-terrorist one-of neighbour-terrorists
        face target-terrorist
        rt 180
        fd 1
      ]
    ]
    [
      follow-leader
    ]
  ]
  [
    ifelse group_no = 0 or (group_no > 0 and leader? = true)
    [
      ifelse close-wall = nobody and exit-patch = nobody
      [
        ifelse know-exit = true
        [
          know-path
        ]
        [
          follow-path
        ]
      ]
      [
        know-path
      ]
    ]
    [
      follow-leader
    ]
  ]
end

to direction-movement
  if length journey_list >= 2
  [
    let outer_one_x_latest  item 0 journey_list
    let inner_one_x_latest  item 1 outer_one_x_latest

    let outer_one_x_previous item 1 journey_list
    let inner_one_x_previous item 1 outer_one_x_previous

    let x_change  inner_one_x_latest -  inner_one_x_previous

    ;; FOR Y co-ords

    let outer_one_y_latest  item 0 journey_list
    let inner_one_y_latest  item 2 outer_one_y_latest

    let outer_one_y_previous item 1 journey_list
    let inner_one_y_previous item 2 outer_one_y_previous

    let y_change  inner_one_y_latest -  inner_one_y_previous

    if x_change != 0 or  y_change != 0
    [
      set  direction_moved heading
    ]

  ]

end

to know-path
  let p min-one-of neighbors [dist]  ;; or neighbors4
  if [dist] of p < dist
  [
    face p
    move-to p
  ]
end

to follow-path

  let neighbour-patches patches in-cone vision-distance vision-angle
  let neighbour-civilia civilians-on  neighbour-patches
  let neighbour-civilians neighbour-civilia with [color = magenta]
  let directions_angles []

  ifelse any? neighbour-civilians
  [
    ask neighbour-civilians
    [
      if direction_moved != 0
      [
        set directions_angles fput ( direction_moved ) directions_angles
      ]
    ]
    if length directions_angles != 0
    [
      let max-dir-list modes directions_angles
      let max_no_follow  item 0 max-dir-list
      set heading max_no_follow
      fd 1
    ]
  ]
  [
    rt random 360
    fd 1
  ]

end

to follow-leader

  let mygroup group_no
  let leader-civilian civilians with [group_no = mygroup and leader? = true ]
  let directions_angles []


  ifelse any? leader-civilian
  [
    ask leader-civilian
    [
      if direction_moved != 0
      [
        set directions_angles fput ( direction_moved ) directions_angles
      ]
    ]
    if length directions_angles != 0
    [
      let max-dir-list modes directions_angles
      let max_no_follow  item 0 max-dir-list
      let close-wall one-of neighbors with [ pcolor = yellow or pcolor = black  ] in-radius 3

      ifelse close-wall != nobody
      [
        face close-wall
        rt 180
        fd 1
      ]
      [
        set heading max_no_follow
        fd 1
      ]
    ]
  ]
  [
    know-path
  ]

end



to reached-safe-zone
  ask patches with [pcolor = green] [
    ask civilians in-radius 1
    [
      set people-reached-safe-zone people-reached-safe-zone + 1
      die
    ]
  ]
end



to check-stampede

  let no-of-turtles count turtles-on patch-here

  let patch_zone [p_type] of patch-here

  if initial-blood < stampede-minimum-threshold
  [

    if no-of-turtles >= 2 and patch_zone != "safe"
    [
      ;print(no-of-turtles)
      set initial-blood initial-blood - 10
    ]

  ]


end



to check-death
  if initial-blood <= 0
  [
    set people-killed-by-stampede people-killed-by-stampede  + 1
    die
  ]
end



to follow-signs
  let walls one-of patches with [p_type = "sign"] in-cone vision-distance vision-angle

  if walls != nobody [
      set know-exit  true
      set color magenta
  ]
end


;;-------------------------- Verification ---------------------------------------------------

to verify-setup
  print "for verify-setup "
  let wall_count count patches with [pcolor = black]
  let sign_count count patches with [pcolor = yellow]
  let exit_count count patches with [pcolor = green]
  ifelse  wall_count != 0 and sign_count != 0 and exit_count != 0
  [
    print "\n\nEncironemnt setup is valid. "
  ]
  [
    print "\n\nEnvironment setup failed."
  ]
  type "\n No.of civilians : " type count civilians type "\n"
  type "\n No.of terrorisits : " type count terrorists type "\n"
  type "\n No.of rescue agents : " type count rescuers type "\n"
  let x count civilians with [know-exit = true]
  type "percentage  of known (calculated) : " type ((x / count civilians) * 100)
end


to verify-blood-distributions ;; to check for random normal distribution of blood

  let blood_levels []
  print "\n\nfor Civilian verify-blood-distributions"
  ask civilians[
    set blood_levels fput (initial-blood) blood_levels
  ]

  type "\nstandard deviation : " type standard-deviation blood_levels
  type "\nmean : " type mean blood_levels

  type "\ndifference in standard deviation(calculated - original) : " type  standard-deviation blood_levels - civilian-blood-sd
  type "\ndifference in mean(calculated - original) : " type  (mean blood_levels) - civilian-blood-mean

end

;;----------------------- Validation ----------------------------------------------------

to validate-civilians
  clear-all
  set queue []
  setup-world
  set civilians-count 100
  setup-civilians
  setup-exits
  setup-signs
  if rescuers-switch
  [
    setup-rescuers
  ]
  bfs
  reset-ticks
end
to go-validation
  if count civilians = 0
  [
    type "\nNo.of people survived : " type people-reached-safe-zone
    type "\n ticks taken to complete" type ticks
    if people-reached-safe-zone = civilians-count
    [
      type "\nEveryone escaped because there are no terrorists and stampede"
    ]
    stop
  ]
  ask civilians
  [
    civilian-movement
    ;;check-stampede
    check-death
    reached-safe-zone
    follow-signs
  ]
  if rescuers-switch
  [
    ask rescuers
    [
      rescue-movement
    ]
  ]

  tick
end
@#$#@#$#@
GRAPHICS-WINDOW
298
30
1343
780
-1
-1
6.87
1
10
1
1
1
0
0
0
1
0
150
0
107
0
0
1
ticks
30.0

BUTTON
49
87
112
120
setup
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

SWITCH
27
139
136
172
exit-signs
exit-signs
0
1
-1000

SLIDER
16
197
188
230
civilians-count
civilians-count
0
2500
494.0
1
1
NIL
HORIZONTAL

SLIDER
15
246
187
279
civilian-blood-mean
civilian-blood-mean
50
150
109.0
1
1
NIL
HORIZONTAL

SLIDER
17
297
189
330
civilian-blood-sd
civilian-blood-sd
0
60
26.0
1
1
NIL
HORIZONTAL

SLIDER
16
353
194
386
Percentage-know-exits
Percentage-know-exits
0
100
6.0
1
1
NIL
HORIZONTAL

SLIDER
16
409
188
442
civilian-vision-distance
civilian-vision-distance
1
20
3.0
1
1
NIL
HORIZONTAL

SLIDER
16
463
188
496
civilian-vision-angle
civilian-vision-angle
0
135
60.0
1
1
NIL
HORIZONTAL

BUTTON
57
525
134
558
go-once
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

BUTTON
59
596
122
629
NIL
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

SLIDER
1507
142
1679
175
terrorists-count
terrorists-count
0
10
6.0
1
1
NIL
HORIZONTAL

SLIDER
1507
201
1679
234
terrorist-blood
terrorist-blood
0
200
200.0
1
1
NIL
HORIZONTAL

SLIDER
1511
253
1683
286
terrorists-vision-dist
terrorists-vision-dist
0
20
6.0
1
1
NIL
HORIZONTAL

SLIDER
1511
321
1683
354
terrorists-vision-angle
terrorists-vision-angle
0
135
52.0
1
1
NIL
HORIZONTAL

CHOOSER
1529
387
1667
432
setup-choices
setup-choices
1 2 3
0

SLIDER
1501
475
1712
508
stampede-minimum-threshold
stampede-minimum-threshold
0
100
81.0
1
1
NIL
HORIZONTAL

MONITOR
1426
568
1621
613
No-of-people-reached-safe-zone
people-reached-safe-zone
17
1
11

MONITOR
1436
659
1591
704
people-killed-by-terrorists
people-killed-by-terrorists
17
1
11

MONITOR
1660
656
1818
701
NIL
people-killed-by-stampede
17
1
11

SLIDER
18
667
191
700
rescue-count
rescue-count
0
10
6.0
1
1
NIL
HORIZONTAL

SLIDER
19
715
192
748
rescue-vision-distance
rescue-vision-distance
0
10
5.0
1
1
NIL
HORIZONTAL

SLIDER
1498
57
1671
90
rescue-vision-angle
rescue-vision-angle
0
135
60.0
1
1
NIL
HORIZONTAL

BUTTON
165
525
265
559
NIL
verify-setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
173
595
343
629
NIL
verify-blood-distributions
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
28
780
150
815
NIL
validate-civilians
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
175
780
280
815
NIL
go-validation
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SWITCH
129
835
267
868
rescuers-switch
rescuers-switch
0
1
-1000

@#$#@#$#@
## WHAT IS IT?

We want to simulate the emergency evacuation scenario particularly in a terrorist attack
scenario with inclusion of detailed modelling of hostage movement such as different levels of
exit awareness, and simulating stampede mechanism and various terrorist attack strategies to
observe survival rate and deaths by terrorist kills as well as natural deaths by stampedes and
how it will be different when Rescue management is present and grouping and remote
grouping,help signs is implemented

## HOW IT WORKS

The environment is built using a blueprint of a real life mall. The entities used in the simulation are hostages, terrorists and rescue squad.

Evacuation process begin when a terrorist starts shooting or when a bomb disposes off. It can be started by people hearing gun shots, alarm sounds or even messages sent by people.
The following are the main procedures in the evacuation simulation process:
• Determine number of hostage agent’s population of the region.
• Hostage agents must follow directions to the exit doors.
• Hostage agents will be stopped when reached the save points.
• Terrorist agents will try to stop and kill as many mobile agents as possible
• Rescue agents will try to save as many Hostage agents and try to counter Terrorist agents

## HOW TO USE IT

Adjust the slider parameters (see below), or use the default settings.

To setup the terrorist attack strategy use the "setup-choices" dropdown to choose :
1. Random
2. Near Exit
3. Centre

Press the SETUP button.
Press the GO button to begin the simulation.


PARAMETERS:

civilians-count: Initial size of civilian population
terrorist-count: Initial size of terrorist population
terrorist-vision-angle: The viewing angle of the terrorist which may range from 0 to 360
terrorist-vision-distance: The viewing distance of the terrorists - i.e they kill civilians who are within their range
civilian-vision-distance: The viewing distance of the civilian - i.e they flee if they find a terrorist nearby or move towards the exits if it's within it's range.
civilian-vision-angle: The viewing angle of the civilian which may range from 0 to 360

For the random normal distribution used to represent the initial energy of a civilian:
civilian-blood-mean: mean of the distribution
civilian-blood-sd: standard deviation of the distribution

terrorist-blood: initial energy a terrorist has
percent-know-exits: The number of civilians who know the exits and their distance from them.
stampede-minimum-threshold: the maximum energy level, below which a civilian loses energy due to stampede in overcrowded rooms.

Look at the monitors to see the 'number of deaths' by stampede and those killed by terrorists.
Look at the 'No of survivors' plot to observe the number of hostages who reach the exit/safe points fluctuate over time.

If there are no civilians left in the mall, the model run stops.


## THINGS TO NOTICE

Panic Grouping and random movements
Basically, this emergency evacuation simulator shows the movement of the agent toward evacuation to the save point.
Agents move to exit points.
Terrorists try to kill people.
Rescue agents try to save as many people as possible.

Look at the monitors to see the 'number of deaths' by stampede and those killed by terrorists.
Look at the 'No of survivors' plot to observe the number of hostages who reach the exit/safe points fluctuate over time.

## THINGS TO TRY

Try out the different attack strategies of terrorists by choosing from the setup-choices and observe. 
Try to increase the terrorists-vision-range and terrorists-vision-angle to the maximum and observe the number of survivors.
Try to increase the percentage of the people who know exits and observe the number of survivors.
Try out the diffrent combinations of the sliders  civilian-vision-distance and civilian-vision-angle and observe the grouping.
Increase and decrease the stampede-minumum-threshold value and observe the deaths by stampede.
change the values of civilian-blood-mean and civilian-blood-sd and observe the distribution of civilians and deaths by stampede.
Toggle the saftey-exits switch and observer the deaths and civilians movement 
  


## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

1. Agent-based modeling of a multi-room multi-floor building emergency evacuation
2. Agent-based Modeling and Simulation for Emergency Scenarios: A Holistic Approach
3. An analysis of evacuation under fire situation in complex shopping center using evacuation simulation modeling

## CREDITS AND REFERENCES

1. Ha, V., & Lykotrafitis, G. (2012). Agent-based modeling of a multi-room multi-floor building emergency evacuation. Physica A: Statistical Mechanics and Its Applications, 391(8), 2740–2751. doi:10.1016/j.physa.2011.12.034
2. Andrea Piccione, Matteo Principe, Alessandro Pellegrini, and Francesco Quaglia. 2019. An Agent-Based Simulation API for Speculative PDES Runtime Environments. In Proceedings of the 2019 ACM SIGSIM Conferenceon Principles of Advanced Discrete Simulation (SIGSIM-PADS '19).
3. Ahn, C., Kim, J. and Lee, S., 2016. An analysis of evacuation under fire situation in complex shopping center using evacuation simulation modeling. Procedia-Social and Behavioral Sciences, 218, pp.24-34.
4. A. Cuesta, O. Abreu, A. Balboa, D. Alvear, A new approach to protect soft-targets from terrorist attacks, Saf. Sci. 120 (2019) 877–885.
5. H.J. Huang, R.Y. Guo, Static floor field and exit choice for pedestrian evacuation in rooms with internal obstacles and multiple exits, Phys. Rev. E 78 (2) (2008) 021131.
6. http://www.stats.gov.cn/tjsj/pcsj/rkpc/6rp/indexch.htm.
7. A. Pedahzur, A. Perliger, L. Weinberg, Altruism and fatalism: the characteristics of palestinian suicide terrorists, Deviant Behav. 24 (4) (2003) 405–423.
8. Lu, Peng, et al. "Agent-based modeling and simulations of terrorist attacks combined with stampedes." Knowledge-Based Systems 205 (2020): 106291.
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
NetLogo 6.1.1
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
