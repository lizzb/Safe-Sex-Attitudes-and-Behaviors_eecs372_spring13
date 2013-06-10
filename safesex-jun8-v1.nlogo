;; TODO
;; friendships die??.... assume no
;; turtles monogamous
  ;; if known, assume get treated and cured within ???? ticks?? immediately? not sure yet... ***
;; "socialite"? has more connections to a bunch of random groups rather than one specific friend group
;breed [social-butterflies social-butterfly]
;; assume talk to friends of both genders about safe sex habits?
;; actually... on a turn they have a chance of making a friend and chance of meeting sexual partner (going to party?)...maybe choose one or other
        ;; TODO?????
    ;; if their attitudes towards safe sex are different by a large margin,
    ;; instantly break up


;; Temporary breeds for setting up social groups/cliques
breed [ people person ] ;; default turtle type, will later be changed to male or female
breed [ leaders leader ] ;; "clique leader" in a way - exists to help with creating layout and link between groups

;; Breeds (agentsets) for gender (once social groups/networks established)
breed [males male]
breed [females female]

links-own [ group ] ; a way to access the links in each group

; turtles can only have one sexual partner at a time in this model
undirected-link-breed [sexual-partners sexual-partner] 
undirected-link-breed [friends friend]



;; set female ranges - avg safe sex desire, avg attitude, avg education
;; set male ranges???    

globals
[  
  
  ;; The next two values are determined by the symptomatic? chooser/drop-down
  males-symptomatic?         ;; If true, males will be symptomatic IF infected with an STI
  females-symptomatic?       ;; If true, females will be symptomatic IF infected with an STI
  
  
  ;; The following 2 variables indicate the % effectiveness in preventing the spread
  ;; of an STI. These numbers are based on pregnancy effectiveness, since condom protection
  ;; against sexually transmitted infections varies based on disease/virus type
  perfect-use-effectiveness  ;; The chance of preventing STI spread if condom is used perfectly
  typical-use-effectiveness  ;; The chance of preventing STI spread if condom is used typically
  
  
  ;infection-chance          ;; The chance out of 100 that an infected person
                             ;; will transmit infection during one week of couplehood
                             ;; [set by slider] (default is scale 0 - 100) 
                             
  max-condom-factor         ;; Maximum condom use value
                            ;; Used as an upper bound for generating random chance of using a condom
                            ;; (default is scale 0 - 100)    
                            
  ;average-condom-usage     ;; Average frequency that a person uses protection
                            ;; [set by slider] (default is scale 0 - 100)         
   
  max-coupling-factor       ;; Maximum coupling tendency value
                            ;; Used as an upper bound for generating random chance of coupling (that is nearby)
                            ;; (default is scale 0 - 100)
                            
  average-coupling-tendency ;; Average tendency of a person to couple with another person
                            ;; in order to couple, the pairings must consist of one male and one female agent
                            
  max-friendship-factor     ;; Maximum coupling tendency value
                            ;; Used as an upper bound for generating random chance of making a friend (that is nearby)
                            ;; (default is scale 0 - 100)
  
  average-friendship-tendency ;; Average tendency of a person to make friends with another person
  
  
  average-relationship-length ;; Average number of ticks a sexual parternship/couple will stay together
                              ;; (average-commitment)        
  
  min-init-sex-ed ;; minimum possible starting level of sex education range (low end if no sex education)
  max-init-sex-ed ;; maximum possible starting level of sex education range (if full sex education??)
  
  ;; amount people interact with their same and opposite gender friends
  ;same-gender-interaction-degree
  ;opposite-gender-interaction-degree
  
  ;min-init-group-liking
  ;max-init-group-liking
  
  ;min-init-attitude 9 (set max slider as max-init-attitude) 25 ;; boss was 50, then 31
  ;max-init-attitude 50 (set min slider as min-init-attitude) ;; boss was 50

  


]



turtles-own
[ 
  
  group-membership ; which cluster/friend group the friends and leaders are mainly part of
  ; but this still applies to some social butterflies - assume they have a core friend group 
  ; in addition to more out-of-group links than others
  
  
  
  
  
  safe-sex-likelihood ;; attitude? used for color ********* ;; probability of a BEHAVIOR
  
  attitude  ; feelings about condoms / desire/intention to use condoms
  safe-sex-attitude          ;; The percent chance a person uses protection while in a couple
                      ;; (determined by gender, slider, & normal distribution)
                      
  ;; how much their upbringing (parents' beliefs, life experiences, religious attitudes) encouraged safe sex    
  certainty           ;;mesosystem-condom-encouragement 
  
  ;; JUSTIFICATION
  justification ;sex-education ; the level of accurate education this agent has about safe sex
  
  
  
  group-liking ; how the worker feels about his workgroup
  ;boss-liking  ; how the worker feels about his boss
  
  
  initial-number-friends
  max-number-friends  ;; Set a maximum on the number of friends a person can have
                      ;; because otherwise will keep making friends, moving closer,
                      ;; and all cluster in middle of screen
   
  
  infected?            ;; If true, the person is infected (and infectious)
  known?               ;; The person is infected and knows it (due to being symptomatic)

  
  ;had-std?            ;; If true, the person once had an STD
                      ;; (that they knew of, assume can't go away by itself unless known...?)
                      ;; perhaps a count instead of a boolean?
                      
                      ;; or maybe just never get cured, and use infected instead
   
                      
  ;; dont need this as its own variable
  ;; just update and check when talking to peers                   
  ;peer-had-std-impact ;; the amount of impact a peer having an std has on this person, assume that doesn't fade over time
                      ;; will be updated if more friends get infected, and bigger impact for stronger links
  

  friendship-tendency ;; How likely this person is to make a new friend
  coupling-tendency   ;; How likely the person is to join a couple.
  commitment          ;; How long the person will stay in a couple-relationship.
                       
  coupled?            ;; If true, the person is in a sexually active couple.
  partner             ;; The person that is our current partner in a couple.
  couple-length       ;; How long the person has been in a couple.

]





;;;
;;; SETUP PROCEDURES
;;;

to setup
  clear-all
  setup-globals
  setup-clusters ;; set up social groups/cliques
  setup-people   ;; change breeds to male, female, set individual turtle attributes
  infect-random  ;; infect one random person (user can choose more, if they want)

  
  ; make the network look a little prettier 
  ;; actually... just rearranges it a bit. better to not move it at all?
  ;repeat 15 [ update-network-layout ] ;; was 10
  
  setup-links
  reset-ticks
end




;;
;; ----- setup-globals ----- ;;
;;
to setup-globals
  
  ;set min-init-group-liking 50 ;65
  ;set max-init-group-liking 82
  ;set same-gender-interaction-degree 85 ;hyp1-degree 51
  ;set opposite-gender-interaction-degree 70 ;hyp2-degree 50
  

  
  
  ;; arbitrary #'s....... TODO *****
  set min-init-sex-ed 29
  set max-init-sex-ed 62
  
  ;; The following 2 variables indicate the % effectiveness in preventing the spread
  ;; of an STI. These numbers are based on pregnancy effectiveness, since condom protection
  ;; against sexually transmitted infections varies based on disease/virus type
  set perfect-use-effectiveness 98 ;; The chance of preventing STI spread if condom is used perfectly
  set typical-use-effectiveness 85 ;; The chance of preventing STI spread if condom is used typically
  
  
  ;set had-training false ; only allows training to happen once

  
  ;; Default number of links generated if Group-liking enabled....they talk to coworkers
  ;; i.e. the number of inter-group links created, in addition to a link with the leader
  ;let num-links ( ( average-node-degree - 1 ) * group-size ) / 2
  
  run word "set-" symptomatic?
  
  set max-friendship-factor 10.0 ;; .... edit...?
  
  set max-coupling-factor 10
  set max-condom-factor 11.0
  
  ;; In the AIDS model, these variables are set with sliders
  ;; For simplicity, we set them to predetermined values
  ;; Individual values in each turtle are still set using 
  ;; a random value following a normal distribution
  
  set average-coupling-tendency max-coupling-factor / 2 ;should be less than max-coupling-factor ; 5
  set average-relationship-length 20
  set average-friendship-tendency max-friendship-factor / 2 ;should be less than max-coupling-factor ; 5
  
  

end

;;
;; ----- setup-clusters ----- 
;;
to setup-clusters
  
  create-leaders num-cliques [  ]
  
  ;; The number of total inter-group links between members
  ;; the - 1 accounts for each member linking to the leader
  ;; multiplying by clique-size ensures there are enough for all group members
  ;; then divide by 2, since you only need 1 link to connect 2 people
  let num-links ( ( avg-num-links - 1 ) * clique-size ) / 2
  
  ;; if only 1 cluster, leader setxy 0 0 by default
  if (num-cliques > 1) ;; if more than 1 cluster
  [
    layout-circle leaders 10
    
    ; assume that all leaders interact/are social butterflies/charismatic,
    ; hence why their entire friend group likes them too
    ;; create links between all "leaders" - the central person of the clique/social group
    ask leaders [ create-friends-with other leaders ] 
  ]
  
  let groupID 0
  while [ groupID < num-cliques ]
  [
    create-people clique-size [ set group-membership groupID ]
    
    ;; if only 1 cluster, layout-circle works 14.5
    ;; boss is in the center of the group
    layout-circle people with [group-membership = groupID ] 5 - 0.5 * max( list (num-cliques - 5) (0) )  
    ask people with [group-membership = groupID ]
    [
      setxy xcor + [xcor] of leader groupID ycor + [ycor] of leader groupID 
      create-friend-with leader groupID
    ]
    
    ;; Agents make friendship links with people in their friend circle
    let linkcounts 0
    while [linkcounts < num-links ]
    [
      ask one-of people with [group-membership = groupID]
      [
        let choice (one-of other people with [not link-neighbor? myself and group-membership = groupID])
        if choice != nobody
          [
            create-friend-with choice [ set group groupID ]
            set linkcounts linkcounts + 1
          ] 
      ]
    ]
    
    set groupID groupID + 1
  ]

  ;; comment or uncomment this if you want a group "leader" to be in the center of the friend group
  ;; and also make all the friend groups discrete to begin
  ;; (might form a couple friendships or sexual relationships)
  ;; was only using leaders for spatial setup, but they also connect to other leaders,
  ;; but seems odd having a central friend
  
  ;;ask leaders [ die ] ;; was only using leaders for spatial setup
  ;; ask n-of num-clusters people to link with not link-neighbor? myself and group-membership != ...my group id

end







;;---------------------------------------------------------------------
;;
;; ----- setup-people -----
;; Turn into males and females
;;
to setup-people
  
  ;; Boss-influence factors.... not entirely sure on this meaning either...
;  ifelse (Boss-influence?) [
;    ask friends
;    [
;      set boss-liking min-init-boss-liking + random ( max-init-boss-liking - min-init-boss-liking ) 
;      set sex-education min-init-sex-ed + random ( max-init-sex-ed - min-init-sex-ed )
;    ]
;    ask leaders [ set attitude min-init-att + random ( max-init-att - min-init-att ) ]
;  ]
  
  ask turtles ;; don't actually create turtles here, generated by setup-clusters
  [ 
    
    ;set group-liking min-init-group-liking + random ( max-init-group-liking - min-init-group-liking )
    set initial-number-friends (count friend-neighbors)
    set max-number-friends initial-number-friends + 2 ;; arbitrary number to give some flexibility ;(average-node-degree / 2)

    set breed males                ;; default breed male, change half to female later
    set coupled? false             ;; If true, the person is in a sexually active couple.
    set partner nobody             ;; The person that is our current partner in a couple.
    set infected? false            ;; If true, the person is infected.
    set known? false               ;; The person is infected and knows it (due to being symptomatic)
   
    
    ;; if known, assume get treated and cured within ???? ticks?? immediately? not sure yet...
    
    ;set had-std? false         ;; assumption made is that having only 1 std will deter the person from further unprotected sex
    ;set peer-had-std-impact 0  ;; good starting value...?
    
    ;; The below variables may be different in each turtle, and the values
    ;; follow an approximately normal distribution
    
    
    ;assign-commitment         ;; How long the person will stay in a couple-relationship.
    ;; assign commitment (doesn't change)
    set commitment random-near average-relationship-length 
    
    ;assign-coupling-tendency  ;; How likely the person is to join a couple.
    ;; assign coupling-tendency (doesn't change)
    set coupling-tendency random-near average-coupling-tendency
    
    ;assign-friendship-tendency
    ;; assign friendship-tendency (doesn't change)
    set friendship-tendency random-near average-friendship-tendency ;; How likely the person is to make a friend.
  
  
  
  
  ]
    
  ;; set genders of turtles to be 50% male, 50% female
  ask n-of (count turtles / 2) turtles [set breed females ]
  
  ask turtles
  [ 
    assign-safe-sex-attitude ;; must do gender first!!!
    assign-certainty
    ;;assign-safe-sex-likelihood ;; must do condom use first!!
    set attitude safe-sex-likelihood ;min-init-attitude + random ( max-init-attitude - min-init-attitude )
    set label round attitude
    
    assign-turtle-color    ;; color is determined by likelihood of practicing safe sex
    assign-shape    ;; shape is determined by gender and sick status 
    set size 2.5    ;set size 3; 1.5
  ]  
end


;;
;; Assign population variable values on an approximately "normal" distribution
;; 


;; Helper procedure to approximate a "normal" distribution
;; around the given average value

;; Generate many small random numbers and add them together.
;; This produces a normal distribution of tendency values.
;; A random number between 0 and 100 is as likely to be 1 as it is to be 99.
;; However, the sum of 20 numbers between 0 and 5 is much more likely to be 50 than it is to be 99.

to-report random-near [center]  ;; turtle procedure
  let result 0
  repeat 40 [ set result (result + random-float center) ]
  report result / 20
end


;; The following procedure assigns core turtle variables.  They use
;; the helper procedure RANDOM-NEAR so that the turtle variables have an
;; approximately "normal" distribution around the average values.


to assign-safe-sex-attitude  ;; turtle procedure
  ifelse (is-female? self)
  [ set safe-sex-attitude random-near avg-female-condom-intention ]
  [ set safe-sex-attitude random-near avg-male-condom-intention ]
  ;average-condom-usage
end

to assign-commitment  ;; turtle procedure
  ;; assign commitment (doesn't change)
  set commitment random-near average-relationship-length 
end

to assign-coupling-tendency  ;; turtle procedure
  ;; assign coupling-tendency (doesn't change)
  set coupling-tendency random-near average-coupling-tendency
end

to assign-friendship-tendency  ;; turtle procedure
  ;; assign friendship-tendency (doesn't change)
  set friendship-tendency random-near average-friendship-tendency
end

to assign-certainty
  ;; assign initial certainty
  set certainty random-near avg-mesosystem-condom-encouragement
end

to update-safe-sex-attitude ;;assign-safe-sex-likelihood
  ;; mesosystem has 25% impact on attitude, personal desire has 75%
  ;; weighting justification 25 certainty/affect/mesosystem 75 = attitude 
  ;;set safe-sex-likelihood (condom-use * .75 + certainty * .25)
  
  ;; strongly weighted to previous attitude
  set safe-sex-attitude (safe-sex-attitude * .5 + justification * .25 + certainty * .25)
end


;; (combine certainty + justification) / 2 or weighted
;; average with current attitude


;;---------------------------------------------------------------------
;; ATTITUDE IS YOUR LIKELIHOOD OF PRACTICING SAFE SEX
;to-report calculate-safe-sex-attitude ;;safe-sex-likelihood ;; calculate-attitude
;  report [ ] ;; (justification + certainty)/2 ==> attitude  = likelihood
  ;; but if infected report 100 set just and certain to 100
  ;; friend gets std justification to 100
  ;; but which weighted more?
;end




;; Called if Group-liking? on
;; Causes group members to talk to one another in their group
;to talk-to-group ; turtle procedure
;  let track 0
;       ; if a worker has one link, then they only have a link with their boss, and 
;       ; can't update their opinion due to group opinions
;   while [ track <  hyp1-degree / 100 * ( count my-links - 1 ) ]
;   [ 
;       ; the amount of change is weighted by the degree of the hypothesis, the group-liking,
;       ; and the difference in attitudes between the friend and one of their link neighbors
;       set change-amt change-amt + ( hyp1-degree / 100 ) * ( group-liking / 100 ) * 
;           ( [ attitude ] of one-of link-neighbors - attitude )
;       set track track + 1
;   ]
;end


;; agents talk to their same-gender friends about safe sex attitudes
;talk-to-same-gender-friends



to talk-to-friends  ;; turtle procedure
  
  ;; increment so that you can talk to more friends the more certain you feel in your attitude
  let convoCount 0
   while [ convoCount <  ( certainty / 100 ) * ( count my-friends ) ]  ;;convoCount <  (same-gender-interaction-degree / 100) * ( count my-friends )
   [ 
       ; the amount of change is weighted by the same-gender-interaction-degree, the group-liking,
       ; and the difference in attitudes between the friend and one of their link neighbors
       
       let buddy one-of friend-neighbors
       if (buddy != nobody)
       [
         ;; update attitude
         
         ;; your own certainty matters for changing your own attitude
         ;; you dont care about their certainty, just what they have to back it up
         
         ;; near each other and one same side (above or below 50) give small boost to certainty
         let attitudeChange ( (1 - (certainty / 100 )) * ([ attitude ] of buddy) + ([ attitude ] of buddy - attitude) * justification * [ justification ] of buddy)
       
         set attitude attitude + attitudeChange
       ]
       
       
       ;set change-amt change-amt + ( hyp1-degree / 100 ) * ( group-liking / 100 ) * 
       ;    ( [ attitude ] of one-of friend-neighbors - attitude )
       ;; certainty - likelihood/degree to which attitude changes is inversely proportional to certainty
       ;; 100 - certainty = likelihood/willingness to change attitude

      ;; set attitude attitude + ( same-gender-interaction-degree / 100 ) * ( group-liking / 100 ) * 
      ;;     ( [ attitude ] of one-of friend-neighbors - attitude )
       
       set convoCount convoCount + 1
   ]
  
end


;to talk-to-boss 
;  ; the degree of the hypothesis is used to limit how often the worker talks to his boss,
;  ; since workers will most likely talk to their coworkers more often than they do with their boss
;  if random 100 <= hyp2-degree
;  [
;  ; the worker updates his change-amt by his amount of expertise, liking of his boss, 
;  ; degree of the hypothesis, and the difference in attitude of his boss 
;  set change-amt change-amt + ( 100 - sex-education ) / 100 * ( boss-liking / 100 ) * 
;         ( hyp2-degree / 100 ) * ( [ attitude ] of leader group-membership - attitude )



;; change this somehow to media fear effect?
;; thinking of aids/hiv

;to crit-mass-effect ; worker procedure
  ; to implement this, we assume that even if a worker doesn't have a link with 
  ; all the members of his group, the effect of the technology increases anyway
;  if count workers with [ group-membership = [ group-membership ] of myself and adopt = true ] > 
;     threshold / 100 * (count workers with [ group-membership = [ group-membership ] of myself ] ) 
;     [ set change-amt change-amt + value-of-threshold ]
;end












to setup-links
  ;; don't really need to create any initial relationships, they'll form on their own
  ;ask n-of 1 friends [set breed sexual-partners]

  ask links [assign-link-color]
end




;; ----- assign-shape ----- ;;
;; Set shape based on gender (male or female)
;; and whether or not infected (includes a red dot)
 
to assign-shape ;; turtle procedure
  ifelse infected?
  [
    ifelse is-male? self
    [
      ifelse known?
      [ set shape "male sick" ]
      [ set shape "male sick unknown" ]
    ]
    [
    ifelse known?
      [ set shape "female sick" ]
      [ set shape "female sick unknown" ]
    ]
  ]
  ;; otherwise, the turtle is not infected
  [
    ifelse is-male? self
    [set shape "male"]
    [set shape "female"]
  ]
end

;; ----- assign-turtle-color ----- ;;

;; Color of turtle depends on their attitude towards/propensity to practice safe sex
;; green = more likely to practice safe sex, red/grey? less likely ***

to assign-turtle-color  ;; turtle procedure 
  
;; MAKE GRADIENT......

;; if there was a switch statement for netlogo, this could be where you'd use it
;  if(safe-sex-likelihood > 0) [set color 14]  ;; fix for 5??
;  if(safe-sex-likelihood > 10) [set color 15]   
;  if(safe-sex-likelihood > 20) [set color 16] 
;  if(safe-sex-likelihood > 30) [set color 17] 
;  if(safe-sex-likelihood > 40) [set color 18] 
;  if(safe-sex-likelihood > 47) [set color 19] 
;  if(safe-sex-likelihood > 53) [set color 64] 
;  if(safe-sex-likelihood > 60) [set color 65]
;  if(safe-sex-likelihood > 70) [set color 66]  
;  if(safe-sex-likelihood > 80) [set color 67]  
;  if(safe-sex-likelihood > 90) [set color 68]  
;  if(safe-sex-likelihood > 95) [set color 69]  
  
  if(safe-sex-attitude > 0) [set color 14]  ;; fix for 5??
  if(safe-sex-attitude > 10) [set color 15]   
  if(safe-sex-attitude > 20) [set color 16] 
  if(safe-sex-attitude > 30) [set color 17] 
  if(safe-sex-attitude > 40) [set color 18] 
  if(safe-sex-attitude > 47) [set color 19] 
  if(safe-sex-attitude > 53) [set color 69] 
  if(safe-sex-attitude > 60) [set color 68]
  if(safe-sex-attitude > 70) [set color 67]  
  if(safe-sex-attitude > 80) [set color 66]  
  if(safe-sex-attitude > 90) [set color 65]  
  if(safe-sex-attitude > 95) [set color 64]  
;  green64-69…white....19-14 red

end

;; ----- assign-link-color ----- ;;

;; Color of link indicates type of relationship between the two agents
;; blue is a friendship, magenta is a sexual partnership

to assign-link-color  ;; link procedure
  
  ifelse is-friend? self
    [ set color blue]
    [ set color magenta]
    
  set thickness .15 ; make the link a bit easier to see
end












;;;                                               ;;;
;;; --------------- GO PROCEDURES --------------- ;;;
;;;                                               ;;;

to go

;; on each tick, turtles talk to each other
;; and may have their opinions/attitudes updated

ask turtles ;; possibly add a condition here...
;; like if you're on either end of the spectrum, nothing will change your mind
[
  talk-to-friends
  
      ;if Group-liking? [ talk-to-group ]
      ;if Boss-influence? [ talk-to-boss ]
         
      ; the turtle updates their attitude from the effects of the hypotheses
      ;set attitude attitude + change-amt
      
      set label round safe-sex-attitude ;; attitude
      assign-turtle-color
]
 
  
  ask turtles
  [
    check-infected
    
    ;; If already coupled with a sexual partner, just increase length of relationship
    ;; (turtles are monogamous in this simulation)
    ifelse coupled?
    [ set couple-length couple-length + 1 ]
    
    ;; If they are not coupled, a turtle tries to find a mate

    ;; Any turtle can initiate mating if they are not coupled
    ;; (and random chance permits)
    [ if (random-float max-coupling-factor < coupling-tendency) [ couple ] ]
  ]
  
  ;; give everyone (coupled or not) a chance to make a friend
  ask turtles
  [
    ;; everyone should attempt to make friends on each tick as well
    ;; because otherwise, all the sexual partner links break
    ;; then it becomes single-sex clusters and nothing cool happens
    if (random-float max-friendship-factor < friendship-tendency) [ make-friends ]
  ]
  
  ask turtles [ uncouple ]
  
  ;; then give chance to spread virus
  ask turtles [ spread-virus ]
 
  ;; Stop if every single turtle is infected
  if all? turtles [infected?] [ stop ]
   
   
  ;;maybe no stop condition? based on attitude??
  ;; reach some sort of stable state?
 
 
  ; model ends when all the friends have made a decision / have the same attitutde....??
 ; (so sometimes the model never ends)
 ;if count friends with [ adopt = true or reject = true ] = count friends [ stop ]
  
      
  
  tick
end









;;;
;;; COUPLING/UNCOUPLING/INFECTING PROCEDURES
;;;


to make-friends ;; turtle procedure 

;; FIX THIS TO BE MORE LIKE COUPLING....take itno account friend groups and shit

  let choice (min-one-of other turtles with [not link-neighbor? myself] [distance myself])
   
  if (choice != nobody and (count friend-neighbors <= max-number-friends) and
    [count friend-neighbors] of choice <= [max-number-friends] of choice )
    [ 
      ;; no need to check for gender compatibility,
      ;; everyone can be friends with each other, yay!
        
        if random-float max-friendship-factor < [friendship-tendency] of choice
        [
          create-friend-with choice [ assign-link-color]
        ]
    ]
end



;; People have a chance to couple depending on their gender,
;; their tendency to couple, and if they ..... are friends already, in same work group, or nearby

to couple  ;; turtle procedure 

  ;; ----- Try to find a valid partner -----
  ;; first try existing friend link of opposite sex
  ;; then try opposite sex within friend group, but not a current link
  ;; then try a nearby opposite sex person as a last resort
  ;; (probability of successful coupling decreases for last 2 options)

  let coupling-probability 1.0 ; arbitrary number

  ;; this agent's social/friend group id
  let groupID group-membership


  ;; create variable that we will overwrite
  let potential-partner one-of friend-neighbors 
  
  ;;
  ;; make sure the agent and the potential partner are willing to mate (male + female pair)
  ;;
  ;; for simplicity, only dealing with straight people
  ;; the asking turtle is male and potential partner female, or vice versa
  ;;
  
  
  ;; male agent - wants to find a female potential partner
  ifelse is-male? self
  [
    ;; preferably find a female that is already a friend / look at existing female friends
    set potential-partner (one-of females with [friend-neighbor? myself and not coupled?])
    ;;set potential-partner one-of female friend-neighbors with [not coupled?]
    
    ;; then, try to find a female that is within your friend group, but not a current link
    if (potential-partner = nobody)
    [
      set potential-partner
      (one-of females with [not link-neighbor? myself and not coupled? and group-membership = groupID])
      set coupling-probability 0.8 ; arbitrary number
    ]
    
    ;; as a last resort, try looking for the closest non-linked female
    if (potential-partner = nobody)
    [
      set potential-partner  (min-one-of (females with [not link-neighbor? myself and not coupled?]) [distance myself])
      set coupling-probability 0.3 ; arbitrary number
     ]
    
  ]
  
  ;; female agent - wants to find a male potential partner
  [ 
     ;; preferably find a male that is already a friend / look at existing male friends
    set potential-partner (one-of males with [friend-neighbor? myself and not coupled?])

    ;; then, try to find a male that is within your friend group, but not a current link
    if (potential-partner = nobody)
    [
      set potential-partner
      (one-of males with [not link-neighbor? myself and not coupled? and group-membership = groupID])
      set coupling-probability 0.8 ; arbitrary number
    ]
    
    ;; as a last resort, try looking for the closest non-linked male
    if (potential-partner = nobody)
    [
      set potential-partner
      (min-one-of (males with [not link-neighbor? myself and not coupled?]) [distance myself])
      set coupling-probability 0.2 ; arbitrary number  
    ] 
  ]


  if potential-partner != nobody
    [   
        if ((random-float max-coupling-factor) * coupling-probability) < ([coupling-tendency] of potential-partner) 
        [
          set partner potential-partner
          set coupled? true
          ask partner
          [
            set partner myself
            set coupled? true
          ]
          
          ;; Change breed of link if friends, and create link for sexual relationship regardless
          if (friend-neighbor? partner) [ask friend-with partner [die] ]
          create-sexual-partner-with partner [ assign-link-color]
      ]
    ]
end

;; If two persons are together for longer than either person's 
;; commitment variable allows, the couple breaks up.

to uncouple  ;; turtle procedure
  if coupled? 
  [
    if (couple-length > commitment) or
      ([couple-length] of partner) > ([commitment] of partner)
      [ 
        ;; Break the link between these two turtles
        ;; assume they don't go back to being friends
        ask sexual-partner-with partner [die]
        
        ;; but if you wanted them to "just be friends"... uncomment below
        ;create-friend-with partner [ assign-link-color]
        
        set coupled? false
        set couple-length 0
        ask partner
        [ 
          set couple-length 0
          set partner nobody
          set coupled? false
        ]
        set partner nobody
      ]
  ]
end



;;;;;;;;;;;;;;;;;;;;;;
;; Setup Procedures ;;
;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;
;; Runtime Procedures ;;
;;;;;;;;;;;;;;;;;;;;;;;;

;; Run the simulation
;to go

;;
;; FROM VIRUS ON A NETWORK
;;


to spread-virus
  ;; Only turtles with sexual partners (coupled) can spread an STI
  ask turtles with [infected? and coupled?]
  [
    ;; Since this model simulates sexual relations between a male and a female,
    ;; only one of the partner's desire to use a condom must be strong enough
    ;; to make sure the couple has safe sex
    
    ;; Note that for condom use to occur, both people must want to use one.  If
    ;; either person chooses not to use a condom, infection is possible.  Changing the
    ;; primitive to AND (from or) in the third line will make it such that if either person
    ;; wants to use a condom, infection will not occur.
    
    
    ;; FIX THIS......... TODO ADD CONDOM EFFICACY/EFFECTIVENESS
    
    ;; maybe every time they have safe sex theyhave a better attitude about it?
    
    ;; ADJUST THIS FOR FEMALE AND MALE?????
    if random-float max-condom-factor > safe-sex-attitude or
    random-float max-condom-factor > ([safe-sex-attitude] of partner)
    [
      ;; TODO: factor in imperfect usage of condoms!!!
      if (random-float 100 < infection-chance)
        [ ask partner [ become-infected ] ]  
    ]  
  ]
end


to become-infected  ;; turtle procedure
  set infected? true
  assign-shape
end

;; Don't want check-infect and become infected to happen on same tick
;; not realistic, std symptoms dont instantly show up
to check-infected
  ;; check if agent is male and symptomatic
  if is-male? self and males-symptomatic? and infected?
  [
    set known? true 
    ;set had-std? true
    set justification 100 ;; after getting an std, turtles always want to have safe sex - logical reason
    update-safe-sex-attitude
  ]
  
  if is-female? self and females-symptomatic? and infected?
  [
    set known? true 
    ;set had-std? true
    set justification 100 ;; after getting an std, turtles always want to have safe sex - logical reason
    update-safe-sex-attitude
  ]
  
  assign-shape
  
  ;; Otherwise, don't change their knowledge about known? or had-std?  
end

;;
;; Infect a random turtle (can do multiple times, if you wish)
;;
to infect-random
  if (count turtles > 1)
  [
    ;; because don't want to have to wait for first tick to display appropriate color of dot
    ;; to reflect if this agent's gender is symptomatic and consequent knowledge of infection
    ask n-of 1 turtles with [not infected?]
    [
      become-infected
      check-infected
    ] 
  ] 
end


;;;
;;; SELECT PROCEDURE
;;;
;; User chooses an patient to infect

to select
  let picked? false
  if mouse-down?
  [
      let candidate min-one-of turtles [distancexy mouse-xcor mouse-ycor]
      if [distancexy mouse-xcor mouse-ycor] of candidate < 1
      [
        ask candidate
        [ 
          become-infected
          ;; because don't want to have to wait for first tick to display appropriate color of dot
          ;; to reflect if this agent's gender is symptomatic and consequent knowledge of infection
          check-infected 
          display
          set picked? true
        ]
      ]
  ]
  if picked? [stop]
end 


;; if you want your linked turtles to move spatially closer to each other, call this sometimes
;; but i like seeing them stay in place and watching changes
;; so this doesn't get called currently
to update-network-layout
  layout-spring turtles links 0.3 (world-width / (sqrt count turtles)) 1
end


;;
;; Setter functions for the symptomatic? drop down/chooser
;;
to set-females-symptomatic?
  set females-symptomatic? true
  set males-symptomatic? false
end

to set-males-symptomatic?
  set males-symptomatic? true
  set females-symptomatic? false
end

to set-both-symptomatic?
  set females-symptomatic? true
  set males-symptomatic? true 
end

to set-neither-symptomatic?
  set males-symptomatic? false
  set females-symptomatic? false
end

;;;
;;; REPORTER / MONITOR PROCEDURES
;;;


to-report avg-attitude
  report mean [safe-sex-likelihood] of turtles
end

to-report avg-male-attitude
  report mean [safe-sex-likelihood] of males
end

to-report avg-female-attitude
  report mean [safe-sex-likelihood] of females
end

to-report avg-friends-per-turtle
  report mean [count friend-neighbors] of turtles
end

to-report avg-partners-per-turtle
  report mean [count sexual-partner-neighbors] of turtles
end

to-report num-in-group-friends
  report count friends with [([group-membership] of end1 = [group-membership] of end2 )]
end

to-report num-out-group-friends
  report count friends with [([group-membership] of end1 != [group-membership] of end2 )]
end

to-report num-in-group-partners
  report count sexual-partners with [([group-membership] of end1 = [group-membership] of end2 )]
end

to-report num-out-group-partners
  report count sexual-partners with [([group-membership] of end1 != [group-membership] of end2 )]
end


to-report %infected
  ifelse any? turtles
    [ report 100 * (count turtles with [infected?] / count turtles) ]
    [ report 0 ]
end

to-report %F-infected
  ifelse any? females
  [ report 100 * count females with [infected?] / count females]
  [ report 0 ]
end

to-report %M-infected
  ifelse any? males
  [ report 100 * count males with [infected?] / count males]
  [ report 0 ]
end

;; reporter for attitude measures

;; reporter for propesnity measures


;;
;; Not all reporters need be displayed in the model (to avoid information overload),
;; but readily available if the user wishes to add monitors
;; to view additional demographic information
;;
@#$#@#$#@
GRAPHICS-WINDOW
430
10
809
410
15
15
11.90323
1
10
1
1
1
0
0
0
1
-15
15
-15
15
1
1
1
weeks
30.0

BUTTON
180
330
255
363
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

MONITOR
725
590
790
635
% infected
%infected
2
1
11

MONITOR
560
590
610
635
#F
count females
17
1
11

MONITOR
610
590
660
635
#M
count males
17
1
11

MONITOR
660
590
725
635
# infected
count turtles with [infected?]
17
1
11

PLOT
555
415
805
585
% of Population Infected
weeks
percentage
0.0
10.0
0.0
100.0
true
true
"" ""
PENS
"Total" 1.0 0 -10899396 true "" "plot %infected"
"M" 1.0 0 -13791810 true "" "plot %M-infected"
"F" 1.0 0 -2064490 true "" "plot %F-infected"

MONITOR
395
415
470
460
% F infected
%F-infected
2
1
11

MONITOR
470
415
545
460
% M infected
%M-infected
2
1
11

BUTTON
335
290
405
323
NIL
select
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
305
260
410
288
Select an individual to have an STD
11
0.0
1

MONITOR
395
460
470
505
#F infected
count females with [infected?]
17
1
11

MONITOR
470
460
545
505
#M infected
count males with [infected?]
17
1
11

TEXTBOX
10
205
325
240
Could include parental influences, religious upbringing/teachings, etc. before person reached college
11
0.0
1

BUTTON
235
290
330
323
NIL
infect-random
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

CHOOSER
15
320
107
365
sex-ed-type
sex-ed-type
"full" "abstinence" "none"
1

CHOOSER
855
185
1020
230
symptomatic?
symptomatic?
"males-symptomatic?" "females-symptomatic?" "both-symptomatic?" "neither-symptomatic?"
0

SLIDER
5
45
120
78
num-cliques
num-cliques
1
20
7
1
1
NIL
HORIZONTAL

SLIDER
285
45
430
78
avg-num-links
avg-num-links
2
clique-size - 1
4
1
1
NIL
HORIZONTAL

SLIDER
855
145
1020
178
infection-chance
infection-chance
0
100
100
1
1
NIL
HORIZONTAL

SLIDER
125
45
280
78
clique-size
clique-size
2
35
8
1
1
people
HORIZONTAL

BUTTON
260
330
330
363
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
335
330
405
363
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

MONITOR
835
510
960
555
avg friends per turtle
;;mean [count friend-neighbors] of turtles\navg-friends-per-turtle
3
1
11

MONITOR
965
510
1135
555
avg sexual partners of turtles
;;mean [count sexual-partner-neighbors] of turtles\navg-partners-per-turtle
3
1
11

SLIDER
10
110
220
143
avg-male-condom-intention
avg-male-condom-intention
0
100
30
1
1
NIL
HORIZONTAL

SLIDER
10
145
220
178
avg-female-condom-intention
avg-female-condom-intention
0
100
70
1
1
NIL
HORIZONTAL

SLIDER
10
240
285
273
avg-mesosystem-condom-encouragement
avg-mesosystem-condom-encouragement
0
100
38
1
1
NIL
HORIZONTAL

TEXTBOX
10
90
290
108
Attitude:  Intention/desire to use a condom
11
0.0
1

SLIDER
855
35
1055
68
%-imperfect-condom-usage
%-imperfect-condom-usage
0
100
65
1
1
NIL
HORIZONTAL

SLIDER
855
70
1055
103
media-prevalence
media-prevalence
0
100
0
1
1
NIL
HORIZONTAL

SLIDER
850
365
1057
398
avg-media-consumption
avg-media-consumption
0
100
50
1
1
NIL
HORIZONTAL

TEXTBOX
860
15
1035
33
Environment/External variables
11
0.0
1

TEXTBOX
855
125
985
143
Infection characteristics
11
0.0
1

PLOT
10
375
305
555
Average safe sex likelihood
weeks
percentages
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Total" 1.0 0 -10899396 true "" "plot avg-attitude"
"M" 1.0 0 -13791810 true "" "plot avg-male-attitude"
"F" 1.0 0 -2064490 true "" "plot avg-female-attitude"

MONITOR
840
410
960
455
# in-group friends
num-in-group-friends
17
1
11

MONITOR
840
460
960
505
# out-group friends
num-out-group-friends
17
1
11

MONITOR
965
410
1100
455
# in-group partners
num-in-group-partners
17
1
11

MONITOR
965
460
1100
505
# out-group partners
num-out-group-partners
17
1
11

TEXTBOX
10
10
360
40
Variables to set up a mini social network, consisting primarily of discrete groups with limited links between out-group agents.
11
0.0
1

TEXTBOX
10
190
160
208
Certainty:  
11
0.0
1

TEXTBOX
15
290
230
320
Justification: accurate knowledge about safe sex practices and benefits
11
0.0
1

@#$#@#$#@
## WHAT IS IT? 

This model aims to simulate the spread and development of safe sex attitudes and behaviors in response to the prevalence of a sexually transmitted infection (STI) throughout a social network of of young adults, taking into account how these variables  influence one another and change over time.


## Guiding questions to consider / goals of the model

What factors seem to be most influential in determining whether or not an individual will contract an STI?

What factors influence the spread of attitudes towards safe sex?

Are the two above questions interdependent? What implications could this have for targeting information campaigns to this age group?



## Next steps

Creating custom attitudes for each agent, rather than blanket assumptions about actions
Establishing networks consisting of "friendship" links and "sexual partner" links

 -- Determining what factors inform/influence attitudes towards safe sex (and consequently behaviors), and to what extent they do so [potential options: attitudes of parents/friends/sexual partners, infection history of self or friends, education/awareness of safe sex practices]
 -- Implementing likelihood of proper use of sexual protection based on statistics, and consequently different potential rates of transmission
 -- Investigating whether a female being on birth control is a valid parameter that might impact whether she chooses to engage in safe sex
 -- Implementing (or deciding whether it is valid to implement) whether a particular gender is symptomatic of an STI, therefore becoming aware of it, getting treated, and potentially changing their future behaviors

I will do further research in order to determine and more accurately base some of the assumptions of this model in scientific literature.

## HOW IT WORKS 

Agents in this model are either male or female - the difference between these agents is distinguishable by their shape. Their color indicates their likelihood of engaging in safe sex (red = least likely --> green = most likely). 

An agent's likelihood of engaging in safe sex is a probability that depends on his or her:
-- Attitude:  their personal desire/intention to have safe sex (CONDOM-USAGE) is originally set by sliders dependent on gender.
-- Certainty:  their conviction with which they hold their attitude. The influence of an individual's upbringing, such as parental beliefs and religious attitudes (symbolized by the MESOSYSTEM-CONDOM-ENCOURAGEMENT variable), represents their initial certainty.
-- Justification:  the strength of the logical explanations to back up their attitude. Initially, this will be set to a variable representing a level of sex ed. Experiences such as contracting an STD, or a friend contracting an STD, would increase this parameter.

Each time step (tick), if an agent is coupled, they increment the length of their relationship. The sexual relationship lasts for a limited period of time (based on the commitment levels of each partner), soif their relationship length has gotten too long, the two will break all links to one another when the sexual relationship ends. 

If an agent is does not have a sexual partner on a tick, they attempt to find a mate that is single and of the opposite gender. First they examine their friends, if that is unsuccessful, they try finding a agent within the same social circle that they are not linked to, and as a last resort, they try to find the closest potential mate.

Every agent, regardless of coupled status, has a chance to make a new friend each tick, if their friend count has not already reached a maximum. (A maximum friend count is required so that the clusters remain somewhat discrete and do not form one large clump in the middle of the screen.)

On every tick while the two agents are coupled, if one partner is infected, the other partner is at risk for infection based on a probability of having sex and using protection. If an agent becomes infected through this interaction (and is of a symptomatic gender), they do not realize they are infected until the next tick.











### Simplifying assumptions

This model only simulates heterosexual/heteronormative, college-aged young adults - both male and female. Agents in the simulation can only have a maximum of one partner at a time. The complexities of different types of sexual behaviors (abstinence, long-term monogamy, or strictly hook-ups) are not included in the model.
 
Although STIs may be transmitted through avenues other than sexual behavior, as in drug needles, childbirth, or breastfeeding, this model focuses on the sexual interactions, as they are most common form of transmission - especially in the age demographic in question. Additionally, although there are forms of protection against STIs/STDs other than condoms, it is the form of sexual protection that is most prevalent and accessible for the demographic of interest.

Although some members of the cliques have or develop links to agents in other groups, the social groups are generated at the beginning of the simulation and remain fairly static. Agents cannot change group affiliation over time, and are not able to be part of more than one social group at a time. 

## HOW TO USE IT 


Using the sliders, choose the number of social groups (NUM-CLIQUES) to create and how many people should make up each social group (CLIQUE-SIZE). The agents within the clique are only connected to others within their social group, and will have about AVG-NUM-LINKS "friends", that they are connected to via a blue link. One of these links will be to the central "leader" of the clique. This "leader" is identical to other agents, except it additionally has links to all other clique "leaders", which helps set up a visual layout and generates a very loosely connected social network containing mostly discrete clusters. 

The SETUP button generates this network and assigns unique values to each individual, based on a normal distribution centered around the average values indicated by the sliders AVG-MESOSYSTEM-CONDOM-ENCOURAGEMENT and AVG-MALE-CONDOM-INTENTION/AVG-FEMALE-CONDOM-INTENTION (depends on agent's gender),as well as setting other variables that are not visible to the user in the same fashion (e.g. tendency to make a friend or sexual partner, maximum length of time willing to spend coupled with a sexual partner).

SETUP will infect one person in the population by default. If the user wants to infect another agent, they can do so through pressing the SELECT button and clicking on an agent, or pressing INFECT-RANDOM. This can also be done while the model is running. 

An infected person is denoted with the addition of a dot on their body, and they will have a INFECTION-CHANCE chance of infecting a partner during unprotected sex. If they are of a gender that is symptomatic of the STI (set by the SYMPTOMATIC? chooser), they are aware of their infected status, the dot will be white, and the agent will automatically practice safe sex to protect his or her partners. However, if the agent is not a gender that is symptomatic, the dot will appear black, they will be oblivious to their infected state, and continue their normal probability of practicing safe sex.


Users also determine the likelihood of an individual using a condom and the point at 

To start the simulation, the user should press the GO button. The simulation will run until the GO button is pressed again or the determined stop-percentage has been met, whichever happens first. 

Monitors indicate the percentage of the total population that has been infected, as well as counts and percentages for some demographics. The graph shows the percentage of each gender that is infected.


The user can affect the likelihood of safe sex being practiced, i.e. how likely an individual is to use a condom. If both partners use a condom, there is an additional probability that the condom/protection is used correctly, and consequently different likelihoods of the infection being transmitted. However, if one partner chooses to use a condom while the other does not, the model simulates no use of a condom, and both parties are potentially at risk of infection. This could be explored and altered in possible extensions of this model. 



## THINGS TO NOTICE 


## THINGS TO TRY 

TBA

## EXTENDING THE MODEL 

Symptoms of sexually transmitted infections aren’t always visible or known, and some STIs display symptoms differently in different genders. These factors impact how often a particular gender might choose to get tested or use protection in sexual encounters. To better simulate real-life behaviors, implement the chance that females have a high likelihood of experiencing symptoms, while males do not. If a person experiences symptoms, they can become treated and cured of the infection in some defined amount of time. You can also implement the condition that if a person thinks they are infected, they will definitely use protection. See how these changes impact the outcome of the model.

In different relationships, condom use may vary. Additionally, condoms are not always effective or properly used. To more accurately account for likelihood of condom use and consequent transmission of infections, create different condom-use tendencies for each sexual orientation and create a probability that a condom is ineffective. 



## NETLOGO FEATURES 
n-of is used to split the turtle population into two genders evenly.

Breeds are used for the genders of turtles, as well as for distinguishing friend links from sexual partner links.

The random-near function generates many small random numbers and adds them together to determine individual tendencies. This produces an approximately normal distribution of values across the population.


## RELATED MODELS, CREDITS AND REFERENCES 
Virus
AIDS
Disease Solo
Virus on a Network
STI model (Lizz Bartos & Landon Basham for LS 426, Winter 2013)
Sophia Sullivan Final Project (EECS372 Spring 11): http://modelingcommons.org/browse/one_model/3023
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

female
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 105 285 105 300 135 300 150 225 165 300 195 300 195 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105
Polygon -7500403 true true 90 195 75 255 225 255 180 105 120 105 135 180 135 165 120 105

female sick
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 105 285 105 300 135 300 150 225 165 300 195 300 195 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105
Polygon -7500403 true true 90 195 75 255 225 255 180 105 120 105 135 180 135 165 120 105
Circle -1 true false 113 98 72

female sick unknown
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 105 285 105 300 135 300 150 225 165 300 195 300 195 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105
Polygon -7500403 true true 90 195 75 255 225 255 180 105 120 105 135 180 135 165 120 105
Circle -16777216 true false 113 98 72

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

male
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

male sick
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105
Circle -1 true false 120 105 60

male sick unknown
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105
Circle -16777216 true false 120 105 60

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

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.0.4
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
1
@#$#@#$#@
