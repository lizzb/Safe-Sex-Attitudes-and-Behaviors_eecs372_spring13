
breed [ people person ] ;; default turtle type, will later be changed to male or female
breed [ leaders leader ] ;; "clique leader" in a way - mostly exists to help with creating layout and temporarily link between groups
; (until social butterflies implemented)

;; "socialite"? has more connections to a bunch of random groups rather than one specific friend group
breed [social-butterflies social-butterfly]

;; Breeds (agentsets) for gender
breed [males male]
breed [females female]

undirected-link-breed [sexual-partners sexual-partner] ;; can have multiple???
undirected-link-breed [friends friend]

links-own
[
  group    ; a way to access the links in each group 
  strength ; is there a better way to do this???.... how about strenght increases likelihood of talking to linkmates
]



;; set female ranges - avg safe sex desire, avg attitude, avg education
;; set male ranges???    

globals
[
  change-amt       ; used to keep track of the amt turtles change their opinions each round
  change-counts    ; keeps track of how many adopt/ reject decisions have been made
  change-time      ; keeps track of the time since the last adopt/reject decisions were made
  had-training     ; only allows training to happen once
  
  
 
  
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
  
                            

  
  average-commitment        ;; Number of ticks a sexual parternship/couple will stay together, on average
  
  min-init-sex-ed ;; minimum possible starting level of sex education range (low end if no sex education)
  max-init-sex-ed ;; maximum possible starting level of sex education range (if full sex education??)
  
  
  ;min-init-group-liking 50
  ;max-init-group-liking 82
  ;min-init-attitude 9 (set max slider as max-init-attitude)
  ;max-init-attitude 50 (set min slider as min-init-attitude)
  ;min-init-att (for boss) 50 (set max slider as max-init-att)
  ;max-init-att (for boss) 50 (set min slider as min-init-att)
  
  ;; The next two values are determined by the symptomatic? chooser/drop-down
  males-symptomatic?         ;; If true, males will be symptomatic IF infected with an STI
  females-symptomatic?       ;; If true, males will be symptomatic IF infected with an STI
  
  
 max-number-friends  ;; Set a maximum on the number of friends a person can have because otherwise all cluster in middle
]



turtles-own
[ 
  ;; ---------- Old starter code ---------- ;;
  
  sex-education ; the level of accurate education this agent has about safe sex
  attitude  ; feelings about new technology
  
  group-membership ; which cluster/friend group the friends and leaders are mainly part of
  ; but this still applies to some social butterflies - assume they have a core friend group 
  ; in addition to more out-of-group links than others
  
  group-liking ; how the worker feels about his workgroup
  boss-liking  ; how the worker feels about his boss
  
  ;; how much the turtle takes into consideration the attitude of their sexual partner?
  peer-influence
  sexual-partner-influence
  close-peer-influence
  
  adopt  ; records when a person makes decision to adopt the technology
  reject ; records true when a person makes a decision to reject technology
  
  ;;---------------------------------------------------------------------
  

  ;; if known, assume get treated and cured within ???? ticks?? immediately? not sure yet... ***
  
  had-std?            ;; If true, the person once had an STD
                      ;; (that they knew of, assume can't go away by itself unless known...?)
                      ;; perhaps a count instead of a boolean?
                      
                      ;; or maybe just never get cured, and use infected instead
                      
                      
  peer-had-std-impact ;; the amount of impact a peer having an std has on this person, assume that doesn't fade over time
                      ;; will be updated if more friends get infected, and bigger impact for stronger links
  
  
  infected?            ;; If true, the person is infected (and infectious)
  known?               ;; The person is infected and knows it (due to being symptomatic)

  friendship-tendency ;; How likely this person is to make a new friend
  
  coupling-tendency   ;; How likely the person is to join a couple.
  commitment          ;; How long the person will stay in a couple-relationship. --> change to multiple partner links??
                       
  coupled?            ;; If true, the person is in a sexually active couple.
  partner             ;; The person that is our current partner in a couple.
  couple-length       ;; How long the person has been in a couple.
  

  condom-use          ;; The percent chance a person uses protection while in a couple
                      ;; (determined by slider & normal distribution)
                      
 
]





;;;
;;; SETUP PROCEDURES
;;;

to setup
  clear-all
  setup-globals
  setup-clusters ;; setup nodes
  setup-people   ;; setup nodes
  infect-random  ;; ask n-of initial-outbreak-size turtles [become-infected]
  setup-spatially-clustered-network ;; comment out this line to get more discrete cliques
  setup-links
  reset-ticks
end


;;
;; Setter functions for the symptomatic? drop down/chooser
;;

;; global variables have no question mark
;; so that reporter functions can (easier to read code that way)
;; or... i guess i could just access the global maybe....????

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

;;
;; ----- setup-globals ----- ;;
;;
to setup-globals
  
  set change-counts 0    ; keeps track of how many adopt/ reject decisions have been made
  
  set had-training false ; only allows training to happen once
 
  ;;--------------------------------------------------------------------- 
  
  set max-number-friends  ( ( average-node-degree - 1 ) * group-size ) / 2 ;; Set a maximum on the number of friends a person can have because otherwise all cluster in middle
  
  ;; Default number of links generated if Group-liking enabled....they talk to coworkers
  ;; i.e. the number of inter-group links created, in addition to a link with the leader
  ;let num-links ( ( average-node-degree - 1 ) * group-size ) / 2
  
  run word "set-" symptomatic?
  
  set max-friendship-factor 25.0 ;; .... edit...?
  
  set max-coupling-factor 10.0
  set max-condom-factor 11.0
  
  ;; In the AIDS model, these variables are set with sliders
  ;; For simplicity, we set them to predetermined values
  ;; Individual values in each turtle are still set using 
  ;; a random value following a normal distribution
  
  set average-coupling-tendency max-coupling-factor / 2 ;should be less than max-coupling-factor ; 5
  set average-commitment 20
  set infection-chance 50 ;; %50 chance of being infected by having unprotected sex with infected partner
  set average-friendship-tendency max-friendship-factor / 2 ;should be less than max-coupling-factor ; 5
  
  
  ;; arbitrary #'s....... TODO *****
  set min-init-sex-ed 29
  set max-init-sex-ed 62
end

;;
;; ----- setup-clusters ----- ;;
;;
to setup-clusters
  
  create-leaders num-clusters [  ]
  
  ;; Default number of links generated if Group-liking enabled....they talk to coworkers
  ;; i.e. the number of inter-group links created, in addition to a link with the leader
  let num-links ( ( average-node-degree - 1 ) * group-size ) / 2
  
  
  ;; if only 1 cluster, boss setxy 0 0 by default
  ;; if more than 1 cluster
  if (num-clusters > 1)
  [
    layout-circle leaders 10
    
    ; assume that all leaders interact/are social butterflies/charismatic, hence why their entire friend group likes them too
    ;; create links between all "bosses" - the central person of the clique
    ;; CHANGE THIS SO THAT SOME "SOCIAL BUTTERFLIES" are created --- TODO *****
    ask leaders [ create-friends-with other leaders ] 
  ]
  
  let groupID 0
  while [ groupID < num-clusters ]
  [
    create-people group-size [ set group-membership groupID ]
    
    ;; if only 1 cluster, layout-circle works 14.5
    ;; boss is in the center of the group
    layout-circle people with [group-membership = groupID ] 5 - 0.5 * max( list (num-clusters - 5) (0) )  
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
  
  ;; group liking will always be enabled for my simulation
    ask people [ set group-liking min-init-group-liking + random ( max-init-group-liking - min-init-group-liking )]
  
  ;; Boss-influence factors.... not entirely sure on this meaning either...
;  ifelse (Boss-influence?) [
;    ask friends
;    [
;      set boss-liking min-init-boss-liking + random ( max-init-boss-liking - min-init-boss-liking ) 
;      set sex-education min-init-sex-ed + random ( max-init-sex-ed - min-init-sex-ed )
;    ]
;    ask leaders [ set attitude min-init-att + random ( max-init-att - min-init-att ) ]
;  ]


  ;; comment or uncomment this if you want a group "leader" to be in the center of the friend group
  ;; was only using leaders for spatial setup, but they also connect to other leaders,
  ;; but seems odd having a central friend
  
  ;ask leaders [ die ] ;; was only using leaders for spatial setup
  
  ask people [ set attitude min-init-attitude + random ( max-init-attitude - min-init-attitude ) ]
  

end


;;
;; from virus on a network ;;
;;
to setup-spatially-clustered-network
  let num-links (average-node-degree * count turtles) / 2
  while [count links < num-links ]
  [
    ask one-of turtles
    [
      let choice (min-one-of (other turtles with [not link-neighbor? myself])
                   [distance myself])
      if choice != nobody [ create-friend-with choice ]
    ]
  ]
  ; make the network look a little prettier 
  repeat 15 [ update-network-layout ] ;; was 10
end




to update-network-layout
  ;; put some parameters on this to not group in middle???
  layout-spring turtles links 0.3 (world-width / (sqrt count turtles)) 1
end



;;
;; ----- setup-people -----
;; Turn into males and females
;;
to setup-people
  
  ask turtles ;; don't create turtles here, generated by setup-clusters
  [ 
    set adopt false
    set reject false 
    ; doesn't allow any agents to make a decision about adopting or rejecting the
    ; technology before the simulation starts
    set label attitude 
    
    ;;---------------------------------------------------------------------
    
    set breed males                ;; default breed male, change half to female later
    set coupled? false             ;; If true, the person is in a sexually active couple.
    set partner nobody             ;; The person that is our current partner in a couple.
    set infected? false            ;; If true, the person is infected.
    set known? false               ;; The person is infected and knows it (due to being symptomatic)
   
    
    ;; if known, assume get treated and cured within ???? ticks?? immediately? not sure yet...
    
    set had-std? false         ;; assumption made is that having only 1 std will deter the person from further unprotected sex
    set peer-had-std-impact 0  ;; good starting value...?
    
    ;; The below variables may be different in each turtle, and the values
    ;; follow an approximately normal distribution
    assign-commitment         ;; How long the person will stay in a couple-relationship. --> change to multiple partner links ??
    assign-coupling-tendency  ;; How likely the person is to join a couple.
    assign-condom-use
    
    assign-friendship-tendency
  ]
    
  ;; initial-people / count turtles
  ;; set genders of turtles to be 50% male, 50% female
  ask n-of (count turtles / 2) turtles [set breed females ]
  
  ask turtles
  [ 
    assign-turtle-color    ;; color is determined by gender
    assign-shape    ;; shape is determined by gender and sick status
    set size 2.5    ;set size 3; 1.5
  ]  
end








to setup-links
   
  ;; don't need to create any initial relationships, they'll form on their own
  ;ask n-of (count friends / 4) friends [set breed sexual-partners]

  ask links [assign-link-color]
end




;; ----- assign-shape ----- ;;
;; Set shape based on gender (male or female)
;; and whether or not infected (includes a red dot)
 
to assign-shape ;; turtle procedure
;  ifelse infected?
;  [ ifelse is-male? self
;    [set shape "male sick"]
;    [set shape "female sick"]
;  ]
;  [ ifelse is-male? self
;    [set shape "male"]
;    [set shape "female"]
;  ]
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
  ifelse is-male? self ;; CHANGE THIS to attitude *****
  [set color green]
  [set color grey]
end

;; ----- assign-link-color ----- ;;

;; Color of link indicates whether the relationship between the two agents
;; is a friendship or a sexual partnership

to assign-link-color  ;; link procedure
  ifelse is-friend? self
    [ set color blue set thickness .15]
    [ set color magenta set thickness .15]
end



;;
;; Assign population variable values on an approximately "normal" DISTRIBUTION 
;; (from AIDS model)
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

to assign-condom-use  ;; turtle procedure
  set condom-use random-near average-condom-usage
end

to assign-commitment  ;; turtle procedure
  set commitment random-near average-commitment
end

to assign-coupling-tendency  ;; turtle procedure
  set coupling-tendency random-near average-coupling-tendency
end

to assign-friendship-tendency  ;; turtle procedure
  set friendship-tendency random-near average-friendship-tendency
end


;;
;; Infect random patient 0 (or multiple, if you wish)
;;
to infect-random
  if (count turtles > 1)
  [
    ;; because don't want to have to wait for first tick to display appropriate color of dot
    ;; to reflect if this agent's gender is symptomatic and consequent knowledge of infection
    ask n-of 1 turtles with [not infected?] [ become-infected check-infected ] 
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

to check-for-decision
  ; the turtles check again to see if they are ready to make a decision
      if attitude > 99
      [
        set adopt true 
        set color green
        set attitude 100
      ]
      
      if attitude < 1
      [
        set reject true
        set color red 
        set attitude 0
      ]
      
end



;;;                                               ;;;
;;; --------------- GO PROCEDURES --------------- ;;;
;;;                                               ;;;

to go
 
 ;; from sophia sullivan starter code for reference
 
;  set change-amt 0 ; used to keep track of the amt turtles change their opinions each round
;  ask friends
;  [
;    ; turtles only update opinions until they have made a decision
;    if adopt = false and reject = false
;    [
;      if Group-liking? [ talk-to-group ]
;      if Boss-influence? [ talk-to-boss ]
;         
;      ; the friend updates their attitude from the effects of the hypotheses
;      set attitude attitude + change-amt
;      
      ;check-for-decision
      
;      set label round attitude
;    ]
;  ]
;  
;  ; if the training switch is on, keep track of decisions to have training when
;  ; there have been no new decisions made for a while
;  if Boss-influence? and training? and had-training = false
;  [
;    ifelse training-time?
;    [ 
;      ifelse change-time = training-time
;      [ 
;        ask friends with [ adopt = false and reject = false ]
;        [ set attitude attitude + training-effect ] 
;      ]
;    ;; training-time == false/off
;      [
;      ifelse count friends with [ adopt = true or reject = true ] = change-counts 
;      ; if nobody has made a new decision within 50 ticks, have a training session
;      [
;        ifelse change-time <= 49
;        [ set change-time change-time + 1 ] ; if nobody has made a decision, add a tick
;        ;; change-time > 49
;        [
;          ; having more information will increase people's attitudes 
;          ask friends with [ adopt = false and reject = false ]
;          [ set attitude attitude + training-effect ]
;          
;          ; make sure training doesn't happen again
;          set had-training true
;        ] 
;      ]
;      ; if the friend count is different than change-counts,
;      ; someone has made a decision and the clock resets
;      [
;        set change-time 0
;        set change-counts count friends with [ adopt = true or reject = true ]
;      ]
;    ]
;  ]
;  
  
 ; model ends when all the friends have made a decision
 ; (so sometimes the model never ends)
 ;if count friends with [ adopt = true or reject = true ] = count friends [ stop ]
 
 
 ;;---------------------------------------------------------------------
 
  ;; TODO ***
  ;; everyone should attempt to make friends on each tick as well
  ;; because otherwise, all the sexual partner links break
  ;; then it becomes single-sex clusters and nothing cool happens
  
  ask turtles
  [
    check-infected
    
    ;; if already coupled with a sexual partner, just increase length of relationship (and have chance to infect, later in code)
    ifelse coupled?
    [ set couple-length couple-length + 1 ] ;; this might mean they have to be monogamous....?? ****
    
   ;; could potentially just use this function entirely for incrementing couple-length, strengthening bonds, etc....
   ;[ update-links ] ;; update links if not coupled (instead of moving, since now on a network)

   ;; Any turtle can initiate mating if they are not coupled
   ;; (and random chance permits)

   ;; actually... on a turn they have a chance of making a friend and chance of meeting sexual partner (going to party?)...maybe choose one or other

   ;; turtle is not coupled, give them a chance to couple/want to couple
   ;; maybe do if else and give them a chance to make a friend??
    [ if (random-float max-coupling-factor < coupling-tendency) [ couple ] ]
  ]
  
  ;; give everyone (coupled or not) a chance to make a friend
  ask turtles
  [
    if (random-float max-friendship-factor < friendship-tendency)
    [ make-friends ]
  ]
  
  ;; possibly move uncouple here??
  ask turtles [ uncouple ]
  
  ;; then give chance to spread virus
  ask turtles [ spread-virus ]
  
  
  ;; keep slightly adjusting the layout of the model to be easier to view/understand
  update-network-layout
  
  ;; Stop if every single turtle is healthy???
   ;if all? turtles [not infected?] [ stop ]
   
   
  ;;maybe no stop condition? based on attitude??
  ;; reach some sort of stable state?
 
  
  tick
end




;; ---> instead of moving, perhaps call relink? probabilty of relink?
;; creating/destroying links

to update-links ;; turtle procedure
  ;make-friends
    ;; Create, strengthen, weaken, or break links with friends or sexual partners

  ; Strengthen links with friends or sexual partners
  ;; if no link exists, create a weak one
  ;; if a weak link exists, create a stronger one
  
  ; Weaken links with friends or sexual partners
  ;; if a strong link exists, create a weaker one
  ;; if a weak link exists, destroy the link

  ;; not sure if i should add any more complexity to these rules....
  
  ;; different strengths and types (breeds) of links have different levels of impact
  ;; on safe sex attitudes/behaviors
end




;;;
;;; COUPLING/UNCOUPLING/INFECTING PROCEDURES
;;;


to make-friends ;; turtle procedure 
  
;  let choice (min-one-of (other turtles with [not link-neighbor? myself])
;                   [distance myself])
;  if choice != nobody [ create-friend-with choice ]
;  

  let choice (min-one-of (other turtles with [not link-neighbor? myself]) [distance myself])
  ;let potential-partner one-of friend-neighbors with [not coupled?]
   
  if (choice != nobody and count friend-neighbors <= max-number-friends) ;if potential-partner != nobody
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
;; their tendency to couple, and if they ..... (meet.?)

to couple  ;; turtle procedure 
  
  ;; need to figure out how to change the breed of a link here (from friend to lover)
  ;;***
  ;let potential-partner one-of friends with [not coupled?] ;;one-of (turtles-at -1 0) with [not coupled?] 

;; one of vs one min of???

  ; uncomment this to require that people be friends first before entering a sexual relationship
  ;; first try testing for friends
  let potential-partner one-of friend-neighbors with [not coupled?]

  ;; in case they have no friends, do this... except it might override...
  set potential-partner (min-one-of (other turtles with [not link-neighbor? myself]) [distance myself * 2])

  if potential-partner != nobody
    [ 
      ;;
      ;; check if the agent and the potential partner are willing to mate (male + female pair)
      ;;
      ;; for simplicity, only dealing with straight people
      ;; the asking turtle is male and potential partner female, or vice versa
      ;;
      
      if ( (is-male? self and is-female? potential-partner) or
        (is-female? self and is-male? potential-partner) )
      [ 
        ;; normal coupling probability
        
        if random-float max-coupling-factor < [coupling-tendency] of potential-partner
        [
          set partner potential-partner
          set coupled? true
          ask partner
          [
            set partner myself
            set coupled? true
          ]
          
          ;; CHANGE BREED OF LINK
          ;; fIX THIS
          ;if [partner one-of friend-neighbors]
          ; [ask friend-with partner [die]
          ;]
          create-sexual-partner-with partner [ assign-link-color]
          
        ]
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
        ;; BREAK THE LINK HERE --- BETTER WAY TO DO THIS???? *****
        ask sexual-partner-with partner [die]
        
        ;; or turn back into friends?
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




;;
;; FROM VIRUS ON A NETWORK
;;


to spread-virus
  ask turtles with [infected? and coupled?] ;; was just infected before
  [
    ;; chance to spread infection to sexual partners on every tick
    ;; (that is, if they have any sexual partners)
    ;ask sexual-partner-neighbors with [not infected?]
    ;ask partner?
    ;[
      
      ;; Note that for condom use to occur, both people must want to use one.  If
      ;; either person chooses not to use a condom, infection is possible.  Changing the
      ;; primitive to AND in the third line will make it such that if either person
      ;; wants to use a condom, infection will not occur.


      ;; ADJUST THIS FOR FEMALE AND MALE
      if random-float max-condom-factor > condom-use or
      random-float max-condom-factor > ([condom-use] of partner) ;;one-of sexual-partner-neighbors) 
      [
        if (random-float 100 < infection-chance)
        [ ask partner [ become-infected ] ]  
      ]  
    ;]
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
  if is-male? self and males-symptomatic?
  [
    set known? true 
    set had-std? true
  ]
  
  if is-female? self and females-symptomatic?
  [
    set known? true 
    set had-std? true
  ]
  
  ;  ;; don't change their knowledge state about known? or had-std? otherwise
  
  assign-shape
  
  
end










;; Called if Group-liking? on
;; Causes group members to talk to one another in their group
to talk-to-group ; turtle procedure
  let track 0
       ; if a worker has one link, then they only have a link with their boss, and 
       ; can't update their opinion due to group opinions
   while [ track <  hyp1-degree / 100 * ( count my-links - 1 ) ]
   [ 
       ; the amount of change is weighted by the degree of the hypothesis, the group-liking,
       ; and the difference in attitudes between the friend and one of their link neighbors
       set change-amt change-amt + ( hyp1-degree / 100 ) * ( group-liking / 100 ) * 
           ( [ attitude ] of one-of link-neighbors - attitude )
       set track track + 1
   ]
end

;; perhaps equivalent is choosing to tell sexual partner you ahve std?

;; Called if Boss-influence? on
;; Causes group members to talk to their group boss
to talk-to-boss ; turtle procedure
  ; the degree of the hypothesis is used to limit how often the worker talks to his boss,
  ; since workers will most likely talk to their coworkers more often than they do with their boss
  if random 100 <= hyp2-degree
  [
  ; the worker updates his change-amt by his amount of expertise, liking of his boss, 
  ; degree of the hypothesis, and the difference in attitude of his boss 
  set change-amt change-amt + ( 100 - sex-education ) / 100 * ( boss-liking / 100 ) * 
         ( hyp2-degree / 100 ) * ( [ attitude ] of leader group-membership - attitude )
  ]
end


;; change this somehow to media fear effect?
;; thinking of aids/hiv

;to crit-mass-effect ; worker procedure
  ; to implement this, we assume that even if a worker doesn't have a link with 
  ; all the members of his group, the effect of the technology increases anyway
;  if count workers with [ group-membership = [ group-membership ] of myself and adopt = true ] > 
;     threshold / 100 * (count workers with [ group-membership = [ group-membership ] of myself ] ) 
;     [ set change-amt change-amt + value-of-threshold ]
;end




;;;
;;; REPORTER / MONITOR PROCEDURES
;;;

;to-report females-symptomatic?
;end
;
;to-report males-symptomatic?
;end

to-report avg-friends-per-turtle
  
end

to-report avg-partners-per-turtle
  
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
;; Reporters for percentages of all possible infected demographics
;; Not currently on display in the model (to avoid information overload),
;; but readily available if the user wishes to add monitors
;; to view additional demographic information
;;
@#$#@#$#@
GRAPHICS-WINDOW
350
10
729
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
270
80
345
113
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
360
550
425
595
% infected
%infected
2
1
11

SLIDER
5
235
185
268
average-condom-usage
average-condom-usage
0
100
50
1
1
NIL
HORIZONTAL

MONITOR
310
415
360
460
#F
count females
17
1
11

MONITOR
360
415
410
460
#M
count males
17
1
11

MONITOR
295
550
360
595
# infected
count turtles with [infected?]
17
1
11

PLOT
5
380
280
550
Percentage of Populations Infected
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
"M" 1.0 0 -13345367 true "" "plot %M-infected"
"F" 1.0 0 -2064490 true "" "plot %F-infected"

MONITOR
285
505
360
550
% F infected
%F-infected
2
1
11

MONITOR
360
505
435
550
% M infected
%M-infected
2
1
11

BUTTON
275
195
345
228
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
245
165
350
193
Select an individual to have an STD
11
0.0
1

MONITOR
285
460
360
505
#F infected
count females with [infected?]
17
1
11

MONITOR
360
460
435
505
#M infected
count males with [infected?]
17
1
11

TEXTBOX
125
310
215
340
(doesn't do anything yet)
11
0.0
1

BUTTON
250
120
345
153
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
735
10
827
55
sex-ed-type
sex-ed-type
"full" "abstinence" "none"
1

SWITCH
725
90
890
123
parental-discussion?
parental-discussion?
1
1
-1000

SLIDER
95
340
215
373
religiousness
religiousness
0
100
50
1
1
NIL
HORIZONTAL

SLIDER
5
200
190
233
average-outspokenness
average-outspokenness
0
100
100
1
1
NIL
HORIZONTAL

CHOOSER
845
45
1032
90
symptomatic?
symptomatic?
"males-symptomatic?" "females-symptomatic?" "both-symptomatic?" "neither-symptomatic?"
1

SLIDER
5
10
120
43
num-clusters
num-clusters
1
20
8
1
1
NIL
HORIZONTAL

SLIDER
5
50
165
83
average-node-degree
average-node-degree
1
group-size - 1
6
1
1
NIL
HORIZONTAL

SLIDER
735
225
895
258
hyp1-degree
hyp1-degree
0
100
51
1
1
NIL
HORIZONTAL

SLIDER
735
190
895
223
max-init-group-liking
max-init-group-liking
0
100
82
1
1
NIL
HORIZONTAL

SLIDER
735
155
895
188
min-init-group-liking
min-init-group-liking
0
100
50
1
1
NIL
HORIZONTAL

SWITCH
900
120
1060
153
Boss-influence?
Boss-influence?
0
1
-1000

SWITCH
830
280
930
313
training?
training?
0
1
-1000

SWITCH
935
280
1060
313
training-time?
training-time?
0
1
-1000

SLIDER
900
190
1060
223
max-init-boss-liking
max-init-boss-liking
0
100
100
1
1
NIL
HORIZONTAL

SLIDER
900
155
1060
188
min-init-boss-liking
min-init-boss-liking
0
100
1
1
1
NIL
HORIZONTAL

SLIDER
900
230
1060
263
hyp2-degree
hyp2-degree
0
100
50
1
1
NIL
HORIZONTAL

SLIDER
885
315
1060
348
training-effect
training-effect
0
100
50
1
1
NIL
HORIZONTAL

SLIDER
885
350
1060
383
training-time
training-time
0
500
250
1
1
NIL
HORIZONTAL

SLIDER
915
410
1060
443
max-init-attitude
max-init-attitude
min-init-attitude
100
50
1
1
NIL
HORIZONTAL

SLIDER
765
410
910
443
min-init-attitude
min-init-attitude
0
max-init-attitude
7
1
1
NIL
HORIZONTAL

SLIDER
915
450
1060
483
max-init-att
max-init-att
min-init-att
100
50
1
1
NIL
HORIZONTAL

TEXTBOX
685
485
825
503
Initial attitudes of bosses
11
0.0
1

TEXTBOX
615
420
765
438
Initial attitudes of workers
11
0.0
1

MONITOR
735
280
815
325
NIL
change-time
17
1
11

SLIDER
765
450
910
483
min-init-att
min-init-att
0
max-init-att
50
1
1
NIL
HORIZONTAL

PLOT
440
455
640
605
Number of relationship links
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -10899396 true "" "plot count friends"
"pen-1" 1.0 0 -2674135 true "" "plot count sexual-partners"

SLIDER
835
10
995
43
infection-chance
infection-chance
0
100
50
1
1
NIL
HORIZONTAL

SLIDER
5
165
120
198
vocality
vocality
0
100
50
1
1
NIL
HORIZONTAL

SLIDER
125
165
240
198
propensity
propensity
0
100
50
1
1
NIL
HORIZONTAL

SLIDER
125
10
240
43
group-size
group-size
1
50
11
1
1
NIL
HORIZONTAL

BUTTON
200
235
265
268
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
275
235
345
268
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
675
550
760
595
NIL
count friends
17
1
11

MONITOR
770
550
905
595
NIL
count sexual-partners
17
1
11

@#$#@#$#@
## WHAT IS IT? 

This model aims to simulate the spread of sexually transmitted infections (STIs) throughout a college-aged population, taking into account attitudes and behaviors towards safe sex. 


### Simplifying assumptions

For this model, sexual orientation is not a parameter, and we are only considering heterosexual/heteronormative, college-aged young adults. 
 
Although STIs may be transmitted through avenues other than sexual behavior, as in drug needles, childbirth, or breastfeeding, this model focuses on the sexual interactions, as they are most common form of transmission - especially in the age demographic in question. 

## Guiding questions to consider / goals of the model

What factors seem to be most influential in determining whether or not an individual will contract an STI?

What factors influence the spread of attitudes towards safe sex?

Are the two above questions interdependent? What implications could this have for targeting information campaigns to this age group?



## Next steps

 -- Adjusting from randomly moving agents to networks using the NW extension.
 -- Establishing networks consisting of "friendship" links and "sexual partner" links
 -- Determining what factors inform/influence attitudes towards safe sex (and consequently behaviors), and to what extent they do so [potential options: attitudes of parents/friends/sexual partners, infection history of self or friends, education/awareness of safe sex practices]
 -- Creating custom attitudes for each agent, rather than blanket assumptions about actions
 -- Implementing likelihood of proper use of sexual protection based on statistics, and consequently different potential rates of transmission
 -- Investigating whether a female being on birth control is a valid parameter that might impact whether she chooses to engage in safe sex
 -- Implementing (or deciding whether it is valid to implement) whether a particular gender is symptomatic of an STI, therefore becoming aware of it, getting treated, and potentially changing their future behaviors

I will do further research in order to determine and more accurately base some of the assumptions of this model in scientific literature.

## HOW IT WORKS 

Agents in this model are either male or female - the difference between these agents is distinguished by color (blue for males, pink for females), as well as by shape. 
An infected person is denoted with the addition of a red dot on their body.

If an agent is not in a relationship, they move around semi-randomly within a certain area. As the individuals move around randomly, they may come across a potential sexual partner.
 -- If both partners are attracted to the gender of the other partner, there is a chance these two will have a sexual relationship; it is not guaranteed.
 -- If a couple is formed, they stay next to each other (stationary) for a pre-determined length of time and their respective patches turn gray in order to more easily identify them.
 -- If one partner in the couple is infected, the other partner is at risk for infection if both partners do not use condoms for each week of their relationship. 
 -- The sexual relationship lasts for a limited time, and the two individuals move randomly about once again until they find another potential partner. 

The model stops when the desired percentage of the population is infected (indicated with a slider). 

## HOW TO USE IT 

Using sliders, determine the initial population, including percentages of representations of different sexual orientations. Users also determine the likelihood of an individual using a condom and the point at which the model should stop. Indicating a stop percentage allows the user to see who has (or has not) been infected after the determined percentage has been reached. 

The SETUP button will generate a population based on the user’s determined values. Once the population is initialized, the user presses the SELECT button and clicks on an individual in the simulation to infect with a sexually transmitted infection. This allows the user to observe any patterns that may arise from an initial “patient zero”. 

To start the simulation, the user should press the GO button. The simulation will run until the GO button is pressed again or the determined stop-percentage has been met, whichever happens first. 

Monitors indicate the percentage of the total population that has been infected, as well as counts and percentages for some demographics. The graph shows the percentage of each gender that is infected.

Once the simulation has reached a stopping point, whether by pressing GO a second time or the stop-percentage has been met, the user can press the HIDE INFECTED button. This will only display the remaining members of the population who have yet to be infected. This information could be used when noticing any possible patterns. To return to the entire population, select the SHOW INFECTED button. 

The user can affect the likelihood of safe sex being practiced, i.e. how likely an individual is to use a condom. If both partners use a condom, there is an additional probability that the condom/protection is used correctly, and consequently different likelihoods of the infection being transmitted. However, if one partner chooses to use a condom while the other does not, the model simulates no use of a condom, and both parties are potentially at risk of infection. This could be explored and altered in possible extensions of this model. 



## THINGS TO NOTICE 

If the INITIAL PEOPLE slider is set relatively high (300-500), you can easily notice that couples start forming on top of each other. It appears as though there are 3 or more individuals in a given sexual relationship, but in actuality, some individuals may be occupying the same patch and only one is visible. 


## THINGS TO TRY 

TBA

## EXTENDING THE MODEL 

***(These were suggestions from the STI model that Landon and I created for DTTTL Winter 2013 - I plan to incorporate some of these elements into the model.)***

Symptoms of sexually transmitted infections aren’t always visible or known, and some STIs display symptoms differently in different genders. These factors impact how often a particular gender might choose to get tested or use protection in sexual encounters. To better simulate real-life behaviors, implement the chance that females have a high likelihood of experiencing symptoms, while males do not. If a person experiences symptoms, they can become treated and cured of the infection in some defined amount of time. You can also implement the condition that if a person thinks they are infected, they will definitely use protection. See how these changes impact the outcome of the model.

In different relationships, condom use may vary. Additionally, condoms are not always effective or properly used. To more accurately account for likelihood of condom use and consequent transmission of infections, create different condom-use tendencies for each sexual orientation and create a probability that a condom is ineffective. 

The culture and sexual behavior habits might alter likelihood of transmission for couples depending on their sexual orientation, i.e. heterosexual vs. bisexual vs. homosexual. Choose different probabilities of transmission for couples of different sexual orientations. Notice if higher transmission rates and lower population percentages alters the outcomes. 

## NETLOGO FEATURES 
n-of is used to divide the turtle population into genders and sexual orientations.

Breeds are used for the genders of turtles, as well as for distinguishing friend links from sexual partner links.

Every time-step (tick), a slider’s value is checked against a global variable that holds the value of what the slider’s value was the time-step before. If the slider’s current value is different than the global variable, NetLogo knows to call procedures that adjust the population’s tendencies. Otherwise, those adjustment procedures are not called. 

The random-near function generates many small random numbers and adds them together to determine individual tendencies. This produces an approximately normal distribution of values.

## RELATED MODELS, CREDITS AND REFERENCES 
Virus
AIDS
Disease Solo
Virus on a Network
STI model, created with Landon Basham for LS 426, Winter 2013.
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
Circle -2674135 true false 113 98 72

female sick unknown
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 105 285 105 300 135 300 150 225 165 300 195 300 195 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105
Polygon -7500403 true true 90 195 75 255 225 255 180 105 120 105 135 180 135 165 120 105
Circle -1184463 true false 113 98 72

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
Circle -2674135 true false 120 105 60

male sick unknown
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105
Circle -1184463 true false 120 105 60

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
