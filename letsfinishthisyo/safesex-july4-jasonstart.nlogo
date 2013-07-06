

;;; --------------------------------------------------------------------- ;;;

;; --- Temporary breeds for setting up social groups/cliques --- ;;

;; default turtle type, will later be changed to male or female
breed [ people person ]
breed [ leaders leader ] ;; "clique leader" in a way
                         ;; helps with creating spatial layout and
                         ;; (optional) some initial links between groups

;; Breeds (agentsets) for gender
;; (once social groups/networks established)
breed [males male]
breed [females female]

;; a way to access the links to members of each clique
links-own [ group ]

;; Link breeds - turtles can either be friends, or sexual partners
; In this model, turtles can have multiple friends,
; but only one sexual partner at a time
undirected-link-breed [sexual-partners sexual-partner]
undirected-link-breed [friends friend]


;;; --------------------------------------------------------------------- ;;;
;;;
;;; GLOBAL VARIABLES
;;;
;;; --------------------------------------------------------------------- ;;;

globals
[
  ;; The next 3 values are set by sliders, where default is scale 0 - 100
  
  ;; The chance out of 100 that an infected person will transmit infection
  ;; during one week of couplehood if they have unsafe sex
  ;infection-chance 
  
  ;; Used as an average for generating chance out of 100 that an agent 
  ;; will use/wants to use a condom (depends on gender)
  ;avg-female-condom-intention 
  ;avg-male-condom-intention  
                             
  
  ;; The next two values are used only in assign-sex-ed-level, and
  ;; will be assigned depending on the %-receive-condom-sex-ed slider value
  ;; Average level of accurate knowledge if agent received:
  no-condom-sex-ed-level ;; sex education that did not include/cover condom use
  condom-sex-ed-level    ;; sex education that included condom use for STI protection
  
  
  ;; The next two values are determined by the symptomatic? chooser
  males-symptomatic?   ;; If true, males will be symptomatic IF infected with an STI
  females-symptomatic? ;; If true, females will be symptomatic IF infected with an STI
                                 
  

  ;; The next two values are the maximum value for tendency of any agent 
  ;; to make a friend or sexual partner link on a given turn. (scale 1 to 100)
  ;; Used as an upper bound for generating random chance for individual agents 
  max-friendship-factor ;; Maximum friendship-making-coupling tendency value
  max-coupling-factor   ;; Maximum coupling tendency value (sexual partner)
                     
  ;; The next two values are the average tendency of an agent to form a
  ;; friendship/sexual partnership with another agent
  ;; Both are set to the max factor / 2
  ;; Average tendency of a person to couple with another person
 
  avg-friendship-tendency ;; Average tendency of a person to make friends with another person
  avg-coupling-tendency   ;; Average tendency of a person to couple with another person 
                          ;; in order to couple, the pairings must consist of one male and one female,
                          ;; and both partners must be single/uncoupled

  avg-relationship-length ;; Average number of ticks a sexual parternship/couple will stay together (commitment)
  
  
  ;; weighted percentage that certainty plays
  ;; in influencing an agents likelihood to practice safe sex.... TODO *****
  attitude-weight ;; how attitude...
  certainty-weight ;; ....
  justification-weight ;; ....
  
  certainty-delta ;; the amount that certainty increases on every tick for every agent
                  ;; certainty increases over time, which makes it harder to change an agent's opinion
  
  justification-delta ;; the amount that justification decreases
                            ;; every time an agent thingks they "got away" with unsafe sex
 
]



;;; --------------------------------------------------------------------- ;;;
;;;
;;; Turtle/Agent Variables
;;;
;;; --------------------------------------------------------------------- ;;;

turtles-own
[
  
  ;; The likelihood (0 - 100%) of this agent practicing safe sex (reflects behavior)
  ;; Likelihood is calculated through a weighted function of components of opinion/attitude????
  ;; (attitude, certainty, justification)
  ;; probability of a BEHAVIOR.... used to determine color (and label value)...
  ;; shoudl just be attitude...???
  
  safe-sex-likelihood

  ;; ATTITUDE IS YOUR LIKELIHOOD OF PRACTICING SAFE SEX ;;safe-sex-attitude
  ;; The percent chance a person uses protection while in a couple
  ;; (determined by gender, slider, & normal distribution)
  
  ;; Used to determine likelihood-delta:  ; ***//
  ;; how much their attitude/opinion/likelihood/whatever has changed from the last turn
  old-safe-sex-likelihood 
  
  ;; ATTITUDE:
  ;; The desire that an agent wants to practice/the likelihood they will practice safe sex??
  ;; changes on ticks....
  attitude ;;attitude ; feelings about / desire/intention to use / condoms
  
                      ;; certainty - likelihood/degree to which attitude changes is inversely proportional to certainty
                      ;; 100 - certainty = likelihood/willingness to change attitude
  
  ;; CERTAINTY:
  ;; how emotionally attached/strongly an agent feels about their opinion/attitude
  certainty ;; initially set to mesosystem-condom-encouragement
                      ;; i.e. how much their upbringing encouraged safe sex
                      ;; might consist of parents' beliefs, life experiences, religious attitudes, etc.
  
  ;; JUSTIFICATION:
  ;; the logic or reasoning why they have their opinion, what they have to back up their opinion/attitude
  justification ;; initially set to the level of accurate education this agent has about safe sex and condom usage
  


  had-unsafe-sex? ;; Whether this person had sex without a condom on the last tick
  
  infected? ;; If true, the person is infected (and infectious)
  known?    ;; The person is infected and knows it (due to being symptomatic)
  ;; In this model, agents that know they are infected
  ;; always use condoms to protect their sexual partners
    ;; If an agent is not symptomatic/of a symptomatic gender,
    ;; their known? variable never gets set to true, which 
    ;; may enable an STI to more easily spread through a population ******
  
  coupled? ;; If true, the person is in a sexually active couple.
  partner ;; The person that is our current partner in a couple.
  couple-length ;; How long the person has been in a couple.
  
  friendship-tendency ;; How likely this person is to make a new friend
  coupling-tendency   ;; How likely the person is to join a couple.
  commitment ;; How long the person will stay in a couple/relationship.
  
  
  group-membership ; which cluster/friend group the friends and leaders are mainly part of
                   ; but this still applies to some social butterflies - assume they have a core friend group
                   ; in addition to more out-of-group links than others
  
  num-friends ;; The number of friends that an agent wants to have

]



;;; --------------------------------------------------------------------- ;;;
;;;
;;; SETUP PROCEDURES
;;;
;;; --------------------------------------------------------------------- ;;;

;;
;; Calls all separate setup functions - setting globals, cliques, individuals
;;
;;
to setup
  clear-all
  setup-globals
  setup-clusters ;; set up social groups/cliques
  setup-people   ;; change breeds to male/female, set individual turtle attributes
  
  ;; By default, setup infects one random individual in the model with an STI
  ;; but if you want to also explore spread of attitudes without an STI spreading
  ;; through the population, comment out the line below

  infect-random ;; infect one random person (user can choose more, if they want)

               
  ; To set up, don't initialize any sexual partnerships, since
  ; they'll form on their own (i.e. only create friendship links) 
  ask links [assign-link-color]
  
  reset-ticks
end

;;; --------------------------------------------------------------------- ;;;
;;
;; Initialize global variables
;;
to setup-globals

  set attitude-weight .5
  set certainty-weight .25
  set justification-weight .25
  
  set certainty-delta .1 ;; the amount certainty increases when an agent repeats their attitude
  set justification-delta 2;10 ;; the amount justification decreases when an agent "gets away with" unsafe sex
  
  ;; These could also be set in assign-sex-ed-level
  set no-condom-sex-ed-level 20
  set condom-sex-ed-level 80
  
  ;; Call functions to set whether females and males show symptoms of the STI
  ;; based on value of chooser/drop-down in interface
  run word "set-" symptomatic?
  
  ;; For simplicity, use predetermined values to set these variables
  ;; (compared to AIDS model, which uses sliders) 
  
  set max-friendship-factor 70 ;; .... edit...? 90 ********
  set max-coupling-factor 40   ;; .... edit...? 85
    
  set avg-friendship-tendency (max-friendship-factor / 2)
  set avg-coupling-tendency (max-coupling-factor / 2)
  
  set avg-relationship-length 25
  
end


;;
;; Setter functions for the symptomatic? chooser/drop-down
;;
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



;;; --------------------------------------------------------------------- ;;;
;;
;; Set up social clusters of networked agents
;;
;;
to setup-clusters
  
  create-leaders num-cliques [ ]
  
  ;; The number of total inter-group links between members
  let num-links ( ( avg-num-friends - 1 ) * clique-size ) / 2
  ; The - 1 accounts for each member intially linking to the leader
  ; Multiplying by clique-size ensures there are enough for all group members
  ; Then divide by 2, since you only need 1 link to connect 2 people
  
  ;; if only 1 cluster, leader setxy 0 0 by default
  if (num-cliques > 1) ;; if more than 1 cluster
  [
    ;; The "leaders" are the central person of the clique/social group
    layout-circle leaders 10

    ;; Create links between all "leaders"
    ask leaders [ create-friends-with other leaders ]
    ; Assume that all leaders interact/are social butterflies/charismatic,
    ; hence why their entire friend group likes them too.
  ]
  
  let groupID 0
  while [ groupID < num-cliques ]
  [
    create-people clique-size [ set group-membership groupID ]
    
    ;; if only 1 cluster, layout-circle works 14.5
    ;; leader is in the center of the group
    layout-circle people with [group-membership = groupID ] 5 - 0.5 * max( list (num-cliques - 5) (0) )
    ask people with [group-membership = groupID ]
    [
      setxy xcor + [xcor] of leader groupID ycor + [ycor] of leader groupID
      create-friend-with leader groupID
    ]
    
    ;; Agents make friendship links with people in their clique/friend circle
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
    
    ;; Increment the groupID to differentiate clique ID #'s
    set groupID groupID + 1
  ]
  
  ;; Leaders are used for spatially setting up discrete clusters
  ;; and for providing some links between groups.
  ;; If they are disabled, there are no initial inter-group links,
  ;; but agents might still form friendships or sexual partnerships 
  ;; with agents that are not in their clique.
  if (not social-butterflies?) [ask leaders [ die ] ]
                                                     
end


;;; --------------------------------------------------------------------- ;;;
;;
;; Initialize individual agents by setting gender and unique member variables
;;
;;
to setup-people
  
  ;; Don't actually CREATE turtles here, that's done by setup-clusters
  ask turtles
  [
    ;; Set ideal number of friends for each agent to
    ;; the initial number of friend links they have
    set num-friends (count friend-neighbors)
    
    set breed males ;; Default breed male, change half to female later
    set coupled? false ;; Everyone is initially single
    set partner nobody
    set had-unsafe-sex? false ;; Whether this person had unsafe sex on the last tick
    
    set infected? false ;; Initially, no one is infected
    set known? false
                                       
  ]
  
  ;; Set genders of turtles to be 50% male, 50% female
  ask n-of (count turtles / 2) turtles [set breed females ]
  
  ask turtles
  [
    ;; Individual variables per agent are set randomly following
    ;; a normal distribution based on slider or global values
    assign-normally-distributed-member-variables
    
    ;; GET RID?? TODO
    cap-member-variables
    
    ;; Determine how much this agent's likelihood of practicing safe sex
    ;; has changed since last tick.
    ;; (If likelihoods of all agents stop changing significantly,
    ;; the simulation will stop.)
    update-safe-sex-likelihood
    set old-safe-sex-likelihood safe-sex-likelihood ; ***//

    
    assign-turtle-color ;; Color is determined by likelihood of practicing safe sex
    assign-shape ;; Shape is determined by gender and sick status
    set size 2.5 ;; Make shapes a bit easier to distinguish by increasing size
  ]
end


;;; --------------------------------------------------------------------- ;;;
;;
;; Helper procedure to approximate a "normal" distribution
;; around the given average value

;; Generate many small random numbers and add them together.
;; This produces a normal distribution of tendency values.
;; A random number between 0 and 100 is as likely to be 1 as it is to be 99.
;; However, the sum of 20 numbers between 0 and 5
;; is much more likely to be 50 than it is to be 99.
;; (from the AIDS model)

to-report random-near [center] ;; turtle procedure
  let result 0
  repeat 40 [ set result (result + random-float center) ]
  report result / 20
end


;;
;; Assign values to variables of agents in the population using
;; the helper procedure RANDOM-NEAR so that individual agents variables
;; follow an approximately "normal" distribution around average values.
;;
to assign-normally-distributed-member-variables
  
    ;;
    ;; The below variables will vary for each turtle, and the values
    ;; follow an approximately normal distribution
    ;;
    
    ;; How long the person will stay in a couple-relationship. (doesn't change)
    set commitment random-near avg-relationship-length
    
    ;; How likely the person is to join a couple. (doesn't change)
    set coupling-tendency random-near avg-coupling-tendency
    
    ;; How likely the person is to make a friend. (doesn't change)
    set friendship-tendency random-near avg-friendship-tendency
    
    
    ;; Note: Gender must be set before this is called!
    ;; Assign initial attitude towards safe sex based on gender
    ;; Attitude can change during the simulation through talking to peers
    ;; and potentially becoming aware of contracting an STI .... TODO FIX ******
    ifelse (is-female? self)
    [ set attitude random-near avg-female-condom-intention ]
    [ set attitude random-near avg-male-condom-intention ]
    
    ;; Assign initial certainty based on mesosystem encouragement
    ;; Certainty increases over time naturally, never decreases in this model ****
    set certainty random-near avg-mesosystem-condom-encouragement
    
    ;; Assign initial justification based on sex ed agent received
    ;; Justification can decrease if agent thinks they "got away with" having unsafe sex
    ;; or increase if they contract an STI themselves
    assign-sex-ed-level

end

;;
;; Assign a level of accurate knowledge of safe sex
;; normally distributed around a high or low value
;; based on type of sex ed the agent received.
;; Used to intialize the agent's justification.
;;
to assign-sex-ed-level
  
  ;; Note: The condom-sex-ed level and no-condom-sex-ed-level are
  ;; static global values in this model for convenience. Since
  ;; they are only used here, they could be set locally instead.
  
  ifelse (random 100 <= %-receive-condom-sex-ed)
  [
    ;; If agent received sex ed including condom usage,
    ;; assume knowledge randomly distributed around HIGH value
    ;; (static global value)
    set justification random-near condom-sex-ed-level
  ]
  [
    ;; If agent received sex ed without condom usage,
    ;; Assume knowledge randomly distributed around LOW value
    set justification random-near no-condom-sex-ed-level
  ]
end



;;; --------------------------------------------------------------------- ;;;
;;;
;;; Set color/shape of agents/links
;;;
;;; --------------------------------------------------------------------- ;;;


;;
;; Set shape based on gender (male or female)
;; and whether or not infected (includes a dot)
;;
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


;;
;; Color of the agent reflects their indvidual 
;; likelihood of practicing safe sex
;;
to assign-turtle-color ;; turtle procedure
  
  cap-member-variables ;; call this just in case a variable went out of accepted range
  
  ;update-safe-sex-likelihood ;; ---- call here or no??? no did weird things
  
  ;; Contemplated using the gradient extension here, but chose not to
  ;; If there was a switch statement for netlogo,
  ;; this could be where you'd use it
  
  ;06C106 green - 100% likely to engage in safe sex (using a condom)
  ;FFFFFF white - 50% likely of having safe sex 
  ;C10606   red  - 0% likely to use a condom (100% likely to have unsafe sex)
 
  if (safe-sex-likelihood >= 0)  [ set color [ 193   6   6 ] ] ;; 0-5 % - red
  if (safe-sex-likelihood > 5)  [ set color [ 198  26  26 ] ] ;; 5-10 %
  if (safe-sex-likelihood > 10) [ set color [ 204  51  51 ] ] ;; 10-15 %
  if (safe-sex-likelihood > 15) [ set color [ 210  77  77 ] ] ;; 15-20 %
  if (safe-sex-likelihood > 20) [ set color [ 217 102 102 ] ] ;; 20-25 %
  if (safe-sex-likelihood > 25) [ set color [ 223 127 127 ] ] ;; 25-30 %
  if (safe-sex-likelihood > 30) [ set color [ 229 153 153 ] ] ;; 30-35 %
  if (safe-sex-likelihood > 35) [ set color [ 236 178 178 ] ] ;; 35-40 %
  if (safe-sex-likelihood > 40) [ set color [ 242 204 204 ] ] ;; 40-45 %
  if (safe-sex-likelihood > 45) [ set color [ 248 229 229 ] ] ;; 45-50 %
  
  if (safe-sex-likelihood = 50) [ set color [ 255 255 255 ] ] ;; 50% - white
  
  if (safe-sex-likelihood > 50) [ set color [ 229 248 229 ] ] ;; 50-55 %
  if (safe-sex-likelihood > 55) [ set color [ 204 242 204 ] ] ;; 55-60 %
  if (safe-sex-likelihood > 60) [ set color [ 178 236 178 ] ] ;; 60-65 %
  if (safe-sex-likelihood > 65) [ set color [ 153 229 153 ] ] ;; 65-70 %
  if (safe-sex-likelihood > 70) [ set color [ 127 223 127 ] ] ;; 70-75 %
  if (safe-sex-likelihood > 75) [ set color [ 102 217 102 ] ] ;; 75-80 %
  if (safe-sex-likelihood > 80) [ set color [  77 210  77 ] ] ;; 80-85 %
  if (safe-sex-likelihood > 85) [ set color [  51 204  51 ] ] ;; 85-90 %
  if (safe-sex-likelihood > 90) [ set color [  26 198  26 ] ] ;; 90-95 %
  if (safe-sex-likelihood > 95) [ set color [   6 193   6 ] ] ;; 95-100 % - green
  
  
  ;; The label is just redundant information of the color
  ;; but it is more precise (displays actual value)
  ;; since assign-turtle-color is updated on every tick
  ;; this can be called from within this function
  ifelse (show-labels?)
  [ set label (round safe-sex-likelihood) ]
  [ set label "" ]
    
end


;;
;; Color of link indicates type of relationship between the two agents
;; blue is a friendship, magenta is a sexual partnership
;;
to assign-link-color ;; link procedure
  
  ifelse is-friend? self
    [ set color blue]
    [ set color magenta]
    
  set thickness .15 ; make the link a bit easier to see
end



;;; --------------------------------------------------------------------- ;;;
;;;
;;; GO/RUNTIME PROCEDURES
;;;
;;; --------------------------------------------------------------------- ;;;

;;
;; Run the simulation
;;
to go
  
  ;;; ----- Check for STOP conditions ----- ;;
  
  ;; Stop if every single turtle is infected
  if all? turtles [infected?] [ stop ]
  
  ;; TODO FIX *****
  ;; if some variables arent changing any more then stop....????... 
  ;; reach some sort of stable state?
  if all? turtles [
    safe-sex-likelihood < 0.1 or
    safe-sex-likelihood > 99.9 or
    certainty > 99.9
    ] [stop]
  ; (so sometimes the model never ends)....?? FIX
  
    ;; (If likelihoods of all agents stop changing significantly,
    ;; the simulation will stop.)
 
  ;; record each agent's likelihood before interacting with others,
   ;; and potentially getting/realizing they are infected 
   
  let old-likelihood 0 ;;safe-sex-likelihood ;; temporary variable due to loops for setting
  
  

  ask turtles [ set old-likelihood safe-sex-likelihood 
    set old-safe-sex-likelihood safe-sex-likelihood ; ***//
    ]
  
  ask turtles
  [
    ;; Agents talk to their friends and sexual partner (if any), which
    ;; might impact his/her personal likelihood of practicing safe sex
    talk-to-peers
    
    ;; If already coupled with a sexual partner,
    ;; just increase length of relationship
    ;; (turtles are monogamous in this simulation)
    ifelse coupled? [ set couple-length couple-length + 1 ]
    
    ;; If they are NOT coupled, a turtle tries to find a mate
 
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
    
    ;; If this agent already has reached their maximum limit of friends,
    ;; don't try to create any more friend links
    
    ;; If this agent has not reached their maximum limit of friends,
    ;; try to make a friend / create a friend link
    if ( (count friend-neighbors < num-friends) and
         random-float max-friendship-factor < friendship-tendency )
    [ make-friends ]
  ]
  
  ;; Agents will uncouple if the length of the relationship reaches
  ;; the commitment threshold for one of the partners
  ;; Call uncouple after make-friends and couple, 
  ;; because you wouldnt want exes immediately friending each other again,
  ;; and this model doesn't simulate instant rebounds
  ask turtles [ uncouple ]
  
  ;; If turtles are coupled (have a sexual partner), 
  ;; they will have sex on each tick, and have the potential
  ;; of spreading an STI if they have unprotected sex.
  ask turtles [ have-sex ]
  
  
  ;; TODO: FIGURE OUT BEST PLACE TO PUT THIS *****
  ;; In order to best simulate that STIs may not present symptoms immediately,
  ;; don't check if infected (known determined by being symptomatic)
  ;; until after talking to friends about attitude and having sex
  ask turtles [ check-infected ]
  
  ask turtles
  [ 
    ;cap-member-variables ; make sure no variables got set to < 0 or > 100
    ;; TODO: STILL NECESSARY?!?!
    
    update-safe-sex-likelihood
    
    assign-turtle-color ;; based on safe-sex-likelihood
  ]
  
      ;; likelihood can be changed by both the talk-to-peers and check-infected functions
  ;ask turtles [ set likelihood-delta (safe-sex-likelihood - old-likelihood) 
  ;  set likelihood-delta (safe-sex-likelihood - old-safe-sex-likelihood)
  ;  ];; new - old]

  tick
end

;;; --------------------------------------------------------------------- ;;;






;;; --------------------------------------------------------------------- ;;;
;;
;; Update the likelihood (out of 100) that an agent
;; will practice safe sex (use a condom).
;;
to update-safe-sex-likelihood
  
  cap-member-variables ; make sure no variables got set to < 0 or > 100
  ;; NECESSARY?!?!!? *****
  
  ;; The likelihood of an agent engaging in safe sex behaviors (using a condom)
  ;; is determined by a combination of the agent's:
  ;;   - attitude (desire)
  ;;   - certainty (confidence in opinion/attitude)
  ;;   - justification (knowledgeable background/logical reasoning for attitude)
  
  ;; Likelihood is strongly weighted to.....
  ;;*** previous attitude (likelihood...??)
  
  let attitude-weight1 .75
  let certainty-weight1 .25
  let justification-weight1 .25

 
 ;; cap variables just in case...???
 
  
  ;; Certainty impacts how resistant an agent is to change their attitude
  ;; when talking to others, and how many others the agent interacts with
  ;; Certainty is assumed to be independent of attitude value itself,
  ;; even when the attitude is polarized (close to 100 or close to 0)
  
  ;; need to take into account whether the certainty (and attitude!)
  ;; is over 50 or under 50
  ;; what about 50 exactly...?? *****
  
  ;; JRW
  ;; The likelihood of having safe sex is based on attitude and certainty.
  ;; The baseline likelihood is the attitude.
  ;; If the attitude is heavy towards safe sex, then the likelihood should be as well.
  ;; However, this may be still influenced by their certainty. 
  ;; Just like a high certainty makes one more resilient to change of attitude, it
  ;; should also make them best resist going against their attitude.
  ;; For now, using a basic formula of multiplying these two values. 
  ;; However, may want to consider someting different.
  ;; Right now, certainty is always reducing likelihood to below the attitude.
  ;; Perhaps trying something like (certainty + 50) so that
  ;; a high certainty will increase likelihood but a low certainty will reduce it.
  ;; Lastly, a constant is added at the end.
  ;; This may not be necessary, but let me explain the thinking.
  ;; While attitude and certainty are the major influences on having sex,
  ;; there are other environmental and contextual influences as well.
  ;; These may include things like BAC, partner attractiveness,
  ;; time since last intercourse, length of relationship, etc.
  ;; Since the focus of the model is not these other influences, 
  ;; I thought I'd just roll them all into some arbitrary constant.
  ;; Most of these other influences seem to reduce the likelihood, 
  ;; so some sort of small reduction in likelihood should be in order.
  set safe-sex-likelihood ((attitude / 100) * (certainty / 100) * 100 - 10)    


end

;;---------------------------------------------------------------------
;;
;;
;; Make sure the member variables don't exceed 100
;;
to cap-member-variables ;; turtle procedure
  if (safe-sex-likelihood > 100) [set safe-sex-likelihood 100]
  if (safe-sex-likelihood < 0) [set safe-sex-likelihood 0]
  if (attitude > 100) [set attitude 100]
  if (attitude < 0) [set attitude 0]
  if (certainty > 100) [set certainty 100]
  if (certainty < 0) [set certainty 0]
  if (justification > 100) [set justification 100]
  if (justification < 0) [set justification 0]
end  



;;; --------------------------------------------------------------------- ;;;
;;;
;;; SPREAD ATTITUDES
;;;
;;; --------------------------------------------------------------------- ;;;


;;
;; Agent interacts with its friends (and sexual partner, if any)
;; and potentially alters its personal likelihood of practicing safe sex
;;
to talk-to-peers ;; turtle procedure


  let convoCount 0
  ;;( count my-friends )... should they ALWAYS talk to partner too?
  ;; or just generic? TODO ******
  
  ;; Use certainty to determine how many links this agent talks to per tick
  ;; The more certain a person is in their attitude,
  ;; the more likely they are to discuss it with their peers/links.
  
  ;; NOTE: These "conversations"/"interactions" are one-directional in this model
  while [ convoCount < ( certainty / 100 ) * ( count my-links ) ] 
    [
      
      let peer one-of link-neighbors ;; friends or sexual partner, if any
      if (peer != nobody)
      [
         
          ;; FIX ***************************
          ;; what words? attitude? certainty? justification?

          ;; A person's certainty impacts how likely they are to change their attitude.
          ;; An agent with higher certainty is more resistent to changing their attitude.
          ;; (100 - certainty) is how likely an agent is to adjust their attitude.
          
          ;; However, an agent doesn't care about how confident their peer
          ;; feels about his/her attitude (certainty), s/he only cares about
          ;; what reasoning they have to back up their attitude (justification).
          
          
          ;; An agent grows more certain of their attitude
          ;; (regardless of what that attitude actually is)
          ;; over time ..... every time they express it to someone else ...****
          
          set certainty certainty + certainty-delta
          
          
          ; The amount of change is weighted by the....
          ; and the difference in attitudes between the friend and one of their link neighbors
          
    
          ;; near each other and one same side (above or below 50)
          ;; SHOULD give small boost to certainty
          
                             
          let attitudeChange ((100 - certainty) / 100 ) * ([attitude] of peer - attitude)
                               * (justification / 100) * ([ justification / 100 ] of peer)
          
          ;; ******* Jason added, not sure about it **********
          ;; one part of attitude changing, through communication with peers,
          ;; is update own justifications
          set justification justification + [justification / 100] of peer
          
          
          set attitude (attitude + attitudeChange * .1)
          
          ;; should i update after talking to every person??? *******
          ;; its just a function of the otehr values, so dont htink it matters
          ;update-safe-sex-likelihood
      ]
      set convoCount convoCount + 1
    ]
    
    update-safe-sex-likelihood ;; update personal likelihood based on talking to peers
  
end


;;; --------------------------------------------------------------------- ;;;
;;;
;;; SPREAD STI (potentially) / HAVE SEX
;;;
;;; --------------------------------------------------------------------- ;;;

;;
;; Only turtles with sexual partners (coupled) can spread an STI
;;
;;
to have-sex ;; turtle procedure (only for coupled turtles)
  
    ;; limitations:
    ;; doesnt account for if some people have a all safe sex always policy
    ;; doesnt account for potential conversation at mating which may influence opinion or relationship
    ;; possibly using protection could improve your attitude towards it?
  

  ;ask turtles with [is-female? self and coupled?]
  ;; only ask one gender of a couple, so that this isn't called twice per tick???
  ;; or no, because want each turtle to try mating on each tick incase one is infected and other not??
  
  
  ask turtles with [coupled?]
  [
    ;; ******
    
    ;; Since this model simulates sexual relations between a male and a female,
    ;; only one of the partner's desire to use a condom must be strong enough
    ;; to make sure the couple has safe sex
    
    
    ;; Infection can occur if either person is infected, but the infection is unknown.
    ;; This model assumes that people with known infections will continue to couple,
    ;; but will automatically practice safe sex, regardless of their condom-use tendency.
    
    
    ;; include an extra check / override check?
    ;; if (infected? and known?) or --> have safe sex
   
    ;; ******
   
    ;; Note also that for condom use to occur, both people must want to use one.
    ;; If either person chooses not to use a condom, infection is possible.
    ;; Changing the primitive in the ifelse statement to AND (instead of OR) will make it
    ;; so if either person wants to use a condom, infection will not occur.
    
    ;; Since this model deals with male/female couples,
    ;; extensions might choose to modify this.

    


    
    ;; need to check this logic....... ****
    ;; If neither parter is aware they are infected.... **
    ;;.......
    ifelse ( (not known? and [not known?] of partner) and
             (random-float 100 > safe-sex-likelihood) or   ;; Optional: change this to AND *****
             (random-float 100 > ([safe-sex-likelihood] of partner))
           ) 
    [
      ;; If got past the above conditional, that means the couple had unprotected sex
      set had-unsafe-sex? true
      ask partner [ set had-unsafe-sex? true ]
      
      ;; since the sex should only occur once in a tick,.....??? ***
      ;; should just have one probability of it being passed in a tick 
      if (random-float 100 < infection-chance)
      [
        ;; Spread virus between an infected and non-infected coupled partner duo
        if (infected?) [ ask partner [ become-infected ] ]
        if ([infected?] of partner) [ become-infected ] ;; not sure if i need this if both agents call this on each tick..... ****
      ]
    ]
    [
      set had-unsafe-sex? false
      ask partner [set had-unsafe-sex? false]
      
      ;; This model assumes that safe sex (using a condom) is always 
      ;; 100% effective in preventing the spread of infection - 
      ;; thus there is no random chance of the infection spreading if a condom is used.
      ;; This could be modified in extensions to be more realistic and
      ;; account for factors like incorrect/inconsistent condom usage,
      ;; condom failure, or STIs passed through other means.
    ]
  ]
end




;;; --------------------------------------------------------------------- ;;;
;;;
;;; MAKE FRIENDS (Potential attitude influencers)
;;;
;;; --------------------------------------------------------------------- ;;;

;;
;; Try to make friend links with other turtles
;; (will only be called if the turtle has not reached their maximum friend limit)
;; Uses similar approach as coupling, but gender doesn't matter
;;
to make-friends ;; turtle procedure
  
  ;; This agent's clique (social/friend group) id
  let groupID group-membership
  
  ;; Probability that friendship link will form
  ;; (arbitrary number to overwrite)
  let friending-probability 1.0
  
  ;; Probability of successful coupling decreases if the
  ;; potential friend is not part of the agent's clique
  ;; Note: these are arbitrary numbers that could be adjusted for more realistic modeling
  let in-group-probability 0.8
  let out-group-probability 0.2
  
  ;; No need to check for gender compatibility,
  ;; everyone can be friends with each other, yay!
  ;; However, the potential-friend must not have maxed out their friend count
  
  ;; A valid potential friend must not have reached his/her friend limit
  ;; (but gender is irrelevant).
  
  ;; First, try to find someone in their clique who is not a current link
  let potential-friend ( one-of other turtles with [not link-neighbor? myself
               and group-membership = groupID
               and (count friend-neighbors < num-friends)] )
  ifelse (potential-friend != nobody)
  [
    set friending-probability in-group-probability
  ]
  ;; If they couldn't find a potential friend within their friend group,
  ;; try finding the closest nearby agent
  [
    set potential-friend ( min-one-of (other turtles with [not link-neighbor? myself
                 and (count friend-neighbors < num-friends)]) [distance myself])
    set friending-probability out-group-probability
  ]
  
  if (potential-friend != nobody)
  [
     ;; Use friending-probability to impact chance of successfully becoming friends
     ;; Higher likelihood if they are in the same friend group, lower if they are not
     if ( (random-float 1.0 < friending-probability) and   
          (random-float max-friendship-factor < [friendship-tendency] of potential-friend) )
      [ create-friend-with potential-friend [ assign-link-color] ]
  ]
end



;;; --------------------------------------------------------------------- ;;;
;;;
;;; COUPLING/UNCOUPLING PROCEDURES
;;;
;;; --------------------------------------------------------------------- ;;;

;;
;; People might couple depending on their gender, their tendency to couple,
;; and if they are already friends/in same clique/nearby a potential single mate
;;
           ;; ----- Try to find a valid partner ----- ;;
           ;; 1) try existing friend link of opposite sex
           ;; 2) try opposite sex within friend group, but not a current link
           ;; 3) try a nearby opposite sex person as a last resort
           ;; (probability of successful coupling decreases for last 2 options)
;;
to couple ;; turtle procedure
  
  ;; This agent's clique (social/friend group) id
  let groupID group-membership
  
  ;; Probability that sexual partnership link will form
  ;; (arbitrary number to overwrite)
  let coupling-probability 1.0 
  
  ;; Probability of successful coupling decreases if the
  ;; potential friend is not part of the agent's clique
  ;; Note: these are arbitrary numbers that
  ;; could be adjusted for more realistic modeling
  let friend-probability 0.8
  let in-group-probability 0.6 ;.8
  let out-group-probability 0.3
 
  
  ;; Create variable that we will overwrite
  let potential-partner one-of friend-neighbors
  
  ;; For simplicity, only dealing with straight people (male + female pairs).
  
  ;; Try to find a valid potential sexual partner.
  ;; A valid potential sexual partner must be the opposite gender and not coupled.
  
  ;; Male agent - wants to find a female potential partner
  ifelse is-male? self
  [
    ;; First check out existing female friends
    set potential-partner (one-of females with [friend-neighbor? myself and not coupled?])
    set coupling-probability friend-probability
    
    ;; If that wasn't successful,
    ;; try to find a female within his clique that is not a current friend/link
    if (potential-partner = nobody)
    [
      set potential-partner
      (one-of females with [not link-neighbor? myself and not coupled? and group-membership = groupID])
      set coupling-probability in-group-probability
    ]
    
    ;; As a last resort,
    ;; look for the closest female that is not a link, even if they aren't in your clique
    if (potential-partner = nobody)
    [
      set potential-partner (min-one-of (females with [not link-neighbor? myself and not coupled?]) [distance myself])
      set coupling-probability out-group-probability
    ]
  ]
  
  ;; Female agent - wants to find a male potential partner
  [
    ;; First check out existing male friends
    set potential-partner (one-of males with [friend-neighbor? myself and not coupled?])
    set coupling-probability friend-probability
    
    ;; If that wasn't successful,
    ;; try to find a male within her clique that is not a current friend/link
    if (potential-partner = nobody)
    [
      set potential-partner
      (one-of males with [not link-neighbor? myself and not coupled? and group-membership = groupID])
      set coupling-probability in-group-probability
    ]
    
    ;; As a last resort,
    ;; look for the closest male that is not a link, even if they aren't in your clique
    if (potential-partner = nobody)
    [
      set potential-partner
      (min-one-of (males with [not link-neighbor? myself and not coupled?]) [distance myself])
      set coupling-probability out-group-probability
    ]
  ]
  
  ;; Finally, if they found a person who meets the above criteria,
  ;; Determine if potential partner is willing to couple with them
  if potential-partner != nobody
    [
      ;; Use coupling-probability to impact chance of successfully forming relationship
      ;; Highest likelihood if agents were already friends, lowest likelihood if agents weren't from same clique
      
       if ( (random-float 1.0 < coupling-probability) and   
          (random-float max-coupling-factor < [coupling-tendency] of potential-partner) )
        [
          set partner potential-partner
          set coupled? true
          ask partner
          [
            set partner myself
            set coupled? true
          ]
          
          ;; Change breed of link if friends,
          ;; and create link for sexual relationship regardless
          if (friend-neighbor? partner) [ask friend-with partner [die] ]
          create-sexual-partner-with partner [ assign-link-color]
        ]
    ]
end


;;
;; If two persons are together for longer than either person's
;; commitment variable allows, the couple breaks up.
;;
to uncouple ;; turtle procedure
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



;;; --------------------------------------------------------------------- ;;;
;;;
;;; INFECTING PROCEDURES 
;;;
;;; --------------------------------------------------------------------- ;;;

;;
;; Turtle becomes infected
;;
to become-infected ;; turtle procedure
  set infected? true
  assign-shape ;; infected turtles have a dot on their shape
  
  ; Note that the turtle will not "know" they are infected
  ; (and set the known? variable) until check-infected is called
end


;;---------------------------------------------------------------------

;; In the next two procedures, users can infect an agent in the model
;; infect-random will choose a random agent, while select allows the 
;; user to choose an agent to infect with the mouse.
;; At least one function should be used at the beginning of the model run,
;; but they can be called at any time during the simulation

;; Note that in both of these procedures, the infected agent 
;; will not "know" they are infected until check-infected is called,
;; and even then, they will only be aware of their infected state
;; if his/her gender is symptomatic.

;; By doing it this way, the agents have a chance to spread the STI
;; before they realize they are infected

;;
;; Infect a random turtle (can do multiple times, if user wishes)
;;
to infect-random
  if (count turtles > 1)
  [
    ask n-of 1 turtles with [not infected?]
    [ become-infected ]
  ]
end

;;
;; User selects an agent in the model to infect with the mouse
;;
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
          set picked? true
        ]
    ]
  ]
  if picked? [stop]
end


;;; --------------------------------------------------------------------- ;;;
;;;
;;; CHECK-INFECTED PROCEDURE
;;;
;;; --------------------------------------------------------------------- ;;;

;;---------------------------------------------------------------------
;;
;; Turtle checks for signs of infection (symptoms)
;; Don't want check-infect and become-infected to happen on same tick
;; --> not realistic, std symptoms don't instantly show up
;;
;; Otherwise, if not symptomatic, don't change their known? variable
;;

to check-infected
  
  ;; DOES THE LOGIC HERE INTERFERE WITH WHEN THE CHECK-INFECTED IS CALLED???
  
  ;; Justification decreases when an agent thinks they had unsafe sex 
  ;; and observes no negative consequences (i.e. didn't contract an STI,
  ;; or doesn't feel symptoms, regardless of whether s/he is actually infected).
  
  if ( had-unsafe-sex? and ( not infected? or
     (is-male? self and not males-symptomatic?) or
     (is-female? self and not females-symptomatic?) )
     )
  [ set justification (justification - justification-delta) ]

    
  ;; ***********
  ;; What if they had safe sex, and didn't get infected.
  ;; That should be some (small) evidence to the benefits
  ;; of protection and increase their justification, if only slightly
  ;; ***********
  
  ;; If an agent is infected and realizes it (due to being symptomatic)
  ;; Their likelihood of practicing safe sex increases significantly,
  ;; due to.... **** TODO
  
  if ((infected? and not known?) and
    ((is-male? self and males-symptomatic?) or
    (is-female? self and females-symptomatic?)))
  [
    ;; *********** FIX ME ............
    set known? true
    set justification 100 ;; after getting an std, turtles always want to have safe sex - logical reason
    set attitude 100 ;; also set their attitude towards safe sex to 100% positive
  ]
  
  update-safe-sex-likelihood ; not sure if comment out or not
  assign-turtle-color ;; pretty sure this is already called in go so dont need to
  assign-shape ;; color of dot changes based on whether the agent knows they are infected

end






;;; --------------------------------------------------------------------- ;;;
;;;
;;; REPORTER / MONITOR PROCEDURES
;;;
;;; --------------------------------------------------------------------- ;;;


to-report num-infected
  report count turtles with [infected?]
end

to-report %infected
  ifelse any? turtles
    [ report 100 * num-infected / count turtles ]
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



;; ----- Reporters for safe-sex-attitude measures ----- ;;

;; --------------- Safe sex likelihood  --------------- ;;
;; ------------- (condom use probability) ------------- ;;

to-report avg-safe-sex-likelihood
  report mean [safe-sex-likelihood] of turtles
end

to-report avg-male-safe-sex-likelihood
  report mean [safe-sex-likelihood] of males
end

to-report avg-female-safe-sex-likelihood
  report mean [safe-sex-likelihood] of females
end

;; --------------- Change in likelihood between ticks --------------- ;;

;; Note: take absolute value, otherwise if some turtles are
;; very positively increasing and others are very negatively decreasing,
;; could result in calculating like there is no change occuring
to-report avg-likelihood-change
  report mean [ abs (safe-sex-likelihood - old-safe-sex-likelihood)] of turtles
end

to-report avg-male-likelihood-change
  report mean [abs (safe-sex-likelihood - old-safe-sex-likelihood)] of males
end

to-report avg-female-likelihood-change
  report mean [abs (safe-sex-likelihood - old-safe-sex-likelihood)] of females
end

  ;; Determine how much this agent's likelihood of practicing safe sex
  ;; has changed since last tick.
  ;; (If likelihoods of all agents stop changing significantly,
  ;; the simulation will stop.)

;; --------------- Attitude --------------- ;;
to-report avg-attitude
  report mean [attitude] of turtles
end

to-report avg-male-attitude
  report mean [attitude] of males
end

to-report avg-female-attitude
  report mean [attitude] of females
end

;; --------------- Certainty --------------- ;;
to-report avg-certainty
  report mean [certainty] of turtles
end

to-report avg-male-certainty
  report mean [certainty] of males
end

to-report avg-female-certainty
  report mean [certainty] of females
end

;; --------------- Justification --------------- ;;
to-report avg-justification
  report mean [justification] of turtles
end

to-report avg-male-justification
  report mean [justification] of males
end

to-report avg-female-justification
  report mean [justification] of females
end

;;
;; Not all reporters need be displayed in the model (to avoid information overload),
;; but readily available if the user wishes to add monitors
;; to view additional demographic information
;;

;; Begin somewhat unnecessary reporters that were at one point used for debugging-ish

to-report avg-friends-per-turtle
  report mean [count friend-neighbors] of turtles
end

to-report avg-partners-per-turtle
  report mean [count sexual-partner-neighbors] of turtles
end

to-report num-in-group-friends
  report count friends with [
    ([group-membership] of end1 = [group-membership] of end2 )]
end

to-report num-out-group-friends
  report count friends with [
    ([group-membership] of end1 != [group-membership] of end2 )]
end

to-report num-in-group-partners
  report count sexual-partners with [
    ([group-membership] of end1 = [group-membership] of end2 )]
end

to-report num-out-group-partners
  report count sexual-partners with [
    ([group-membership] of end1 != [group-membership] of end2 )]
end
@#$#@#$#@
GRAPHICS-WINDOW
485
10
873
419
15
15
12.2
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
350
285
475
318
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
880
430
955
475
% infected
%infected
2
1
11

PLOT
625
425
875
575
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
880
530
955
575
% F infected
%F-infected
2
1
11

MONITOR
880
480
955
525
% M infected
%M-infected
2
1
11

BUTTON
305
245
375
278
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
310
225
470
243
Select a person to have an STI
11
0.0
1

TEXTBOX
10
215
275
245
Certainty: Could include parental influences, religious background, etc.
11
0.0
1

BUTTON
380
245
475
278
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
305
175
470
220
symptomatic?
symptomatic?
"males-symptomatic?" "females-symptomatic?" "both-symptomatic?" "neither-symptomatic?"
2

SLIDER
10
30
160
63
num-cliques
num-cliques
1
20
20
1
1
NIL
HORIZONTAL

SLIDER
325
30
465
63
avg-num-friends
avg-num-friends
2
clique-size - 1
2
1
1
NIL
HORIZONTAL

SLIDER
305
135
470
168
infection-chance
infection-chance
0
100
26
1
1
NIL
HORIZONTAL

SLIDER
165
30
320
63
clique-size
clique-size
2
35
35
1
1
people
HORIZONTAL

BUTTON
350
320
410
353
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
415
320
475
353
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
10
135
220
168
avg-male-condom-intention
avg-male-condom-intention
0
100
20
1
1
NIL
HORIZONTAL

SLIDER
10
170
220
203
avg-female-condom-intention
avg-female-condom-intention
0
100
80
1
1
NIL
HORIZONTAL

SLIDER
5
245
280
278
avg-mesosystem-condom-encouragement
avg-mesosystem-condom-encouragement
0
100
30
1
1
NIL
HORIZONTAL

TEXTBOX
10
115
250
133
Attitude: Intention/desire to use a condom
11
0.0
1

TEXTBOX
340
115
475
133
STI characteristics
11
0.0
1

PLOT
335
425
620
575
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
"Total" 1.0 0 -10899396 true "" "plot avg-safe-sex-likelihood"
"M" 1.0 0 -13791810 true "" "plot avg-male-safe-sex-likelihood"
"F" 1.0 0 -2064490 true "" "plot avg-female-safe-sex-likelihood"

TEXTBOX
10
10
475
28
Parameters to initialize a social network, consisting of discrete social groups (cliques).
11
0.0
1

TEXTBOX
10
290
235
320
Justification: accurate knowledge about safe sex practices and benefits
11
0.0
1

SWITCH
10
70
160
103
social-butterflies?
social-butterflies?
1
1
-1000

PLOT
5
380
330
575
Components of Safe Sex Behavior
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
"Attitude M" 1.0 0 -14730904 true "" "plot avg-male-attitude"
"Certainty M" 1.0 0 -13791810 true "" "plot avg-male-certainty"
"Justification M" 1.0 0 -15040220 true "" "plot avg-male-justification"
"Attitude F" 1.0 0 -5298144 true "" "plot avg-female-attitude"
"Certainty F" 1.0 0 -955883 true "" "plot avg-female-certainty"
"Justification F" 1.0 0 -2064490 true "" "plot avg-female-justification"

SLIDER
10
320
227
353
%-receive-condom-sex-ed
%-receive-condom-sex-ed
0
100
42
1
1
NIL
HORIZONTAL

SWITCH
350
370
475
403
show-labels?
show-labels?
0
1
-1000

TEXTBOX
900
105
1050
161
Description of how liklihood is calculated from attitude, certainty, justificaiton...
11
0.0
1

PLOT
885
265
1085
415
Average opinion change
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
"default" 1.0 0 -10899396 true "" "plot avg-likelihood-change"
"pen-1" 1.0 0 -13345367 true "" "plot avg-male-likelihood-change"
"pen-2" 1.0 0 -5825686 true "" "plot avg-female-likelihood-change"

TEXTBOX
165
70
425
100
Enable to initialize a limited number of inter-group links between \"clique leaders\".
11
0.0
1

MONITOR
955
215
1020
260
delta F
avg-female-likelihood-change
17
1
11

MONITOR
885
215
950
260
delta M
avg-male-likelihood-change
17
1
11

PLOT
885
10
1085
160
Safe Sex Likelihood Histogram
likelihood
NIL
0.0
100.0
0.0
25.0
true
false
"set-plot-y-range 0 (count turtles / 2.5)" ""
PENS
"M" 10.0 1 -13345367 true "" "histogram [safe-sex-likelihood] of males"
"F" 10.0 1 -2064490 true "" "histogram [safe-sex-likelihood] of females"

@#$#@#$#@
### NOTE: The documentation accompanying this model, and the comments in the code, are incomplete.


## WHAT IS IT?

This model aims to simulate the spread and development of safe sex attitudes and behaviors in response to the prevalence of a sexually transmitted infection (STI) throughout a social network of of young adults. It also takes into account how these variables influence one another and change over time using theories of attitude change and certainty.


## HOW IT WORKS

Agents in this model are either male or female - the difference between these agents is distinguishable by their shape. Their color indicates their likelihood of engaging in safe sex (red = least likely --> green = most likely).

An agent's likelihood of engaging in safe sex is a probability that depends on his or her:
-- Attitude: their personal desire/intention to have safe sex (CONDOM-USAGE) is originally set by sliders dependent on gender.
-- Certainty: their conviction with which they hold their attitude. The influence of an individual's upbringing, such as parental beliefs and religious attitudes (symbolized by the MESOSYSTEM-CONDOM-ENCOURAGEMENT variable), represents their initial certainty.
-- Justification: the strength of the logical explanations to back up their attitude. Initially, this will be set to a variable representing a level of sex ed. Experiences such as contracting an STD, or a friend contracting an STD, would increase this parameter.

;; On each tick, agents talk to their friends (and partner, if any),
;; and potentially update their attitude about safe sex

Each time step (tick), if an agent is coupled, they increment the length of their relationship. The sexual relationship lasts for a limited period of time (based on the commitment levels of each partner), soif their relationship length has gotten too long, the two will break all links to one another when the sexual relationship ends.

If an agent is does not have a sexual partner on a tick, they attempt to find a mate that is single and of the opposite gender. First they examine their friends, if that is unsuccessful, they try finding a agent within the same social circle that they are not linked to, and as a last resort, they try to find the closest potential mate.

Every agent, regardless of coupled status, has a chance to make a new friend each tick, if their friend count has not already reached a maximum. (A maximum friend count is required so that the clusters remain somewhat discrete and do not form one large clump in the middle of the screen.)

On every tick while the two agents are coupled, if one partner is infected, the other partner is at risk for infection based on a probability of having sex and using protection. If an agent becomes infected through this interaction (and is of a symptomatic gender), they do not realize they are infected until the next tick.


## HOW TO USE IT

Using the sliders, choose the number of social groups (NUM-CLIQUES) to create and how many people should make up each social group (CLIQUE-SIZE). The agents within the clique are only connected to others within their social group, and will have about AVG-NUM-LINKS "friends", that they are connected to via a blue link. One of these links will be to the central "leader" of the clique. This "leader" is identical to other agents, except it additionally has links to all other clique "leaders", which helps set up a visual layout and generates a very loosely connected social network containing mostly discrete clusters.

Whether a central "clique leader" should have links to leaders of other cliques. Initializes limited links between groups, otherwise there are none on setup.


The SETUP button generates this network and assigns unique values to each individual, based on a normal distribution centered around the average values indicated by the sliders AVG-MESOSYSTEM-CONDOM-ENCOURAGEMENT and AVG-MALE-CONDOM-INTENTION/AVG-FEMALE-CONDOM-INTENTION (depends on agent's gender),as well as setting other variables that are not visible to the user in the same fashion (e.g. tendency to make a friend or sexual partner, maximum length of time willing to spend coupled with a sexual partner).

SETUP will infect one person in the population by default. If the user wants to infect another agent, they can do so through pressing the SELECT button and clicking on an agent, or pressing INFECT-RANDOM. This can also be done while the model is running.

An infected person is denoted with the addition of a dot on their body, and they will have a INFECTION-CHANCE chance of infecting a partner during unprotected sex. If they are of a gender that is symptomatic of the STI (set by the SYMPTOMATIC? chooser), they are aware of their infected status, the dot will be white, and the agent will automatically practice safe sex to protect his or her partners. However, if the agent is not a gender that is symptomatic, the dot will appear black, they will be oblivious to their infected state, and continue their normal probability of practicing safe sex.


The model stops when the entire population is infected, or if all agents have reached a single, unchanging safe-sex-attitude of either 0 or 100.


### Simplifying assumptions

This model only simulates heterosexual/heteronormative, college-aged young adults - both male and female. Agents in the simulation can only have a maximum of one partner at a time. The complexities of different types of sexual behaviors (abstinence, long-term monogamy, or strictly hook-ups) are not included in the model.
 
Although STIs may be transmitted through avenues other than sexual behavior, as in drug needles, childbirth, or breastfeeding, this model focuses on the sexual interactions, as they are most common form of transmission - especially in the age demographic in question. Additionally, although there are forms of protection against STIs/STDs other than condoms, it is the form of sexual protection that is most prevalent and accessible for the demographic of interest.

Although some members of the cliques have or develop links to agents in other groups, the social groups are generated at the beginning of the simulation and remain fairly static. Agents cannot change group affiliation over time, and are not able to be part of more than one social group at a time.

if coupled, ahve sex every time! and if not coupled, always looking for a partner


## THINGS TO NOTICE



## THINGS TO TRY

Set one of the genders to not be symptomatic. What happens to their certainty, in comparison to the other gender? What happens to their attitude adjustment overall?



## EXTENDING THE MODEL



Symptoms of sexually transmitted infections aren't always visible or known, and some STIs display symptoms differently in different genders. These factors impact how often a particular gender might choose to get tested or use protection in sexual encounters. To better simulate real-life behaviors, implement the chance that females have a high likelihood of experiencing symptoms, while males do not. If a person experiences symptoms, they can become treated and cured of the infection in some defined amount of time. You can also implement the condition that if a person thinks they are infected, they will definitely use protection. See how these changes impact the outcome of the model.

In different relationships, condom use may vary. Additionally, condoms are not always effective or properly used, and may be used for some sexual acts, but not others. To more accurately account for likelihood of condom use and consequent transmission of infections, create different condom-use tendencies for each sexual orientation and create a probability that a condom is ineffective.


Condom use for the purpose of protection against sexually transmitted diseases (vs. just for pregnancy prevention) increased when fear of HIV/AIDS was prevalent in the media. Incorporate an element of media influence that impacts the attitudes and/or behaviors of the agents.


;; don't need a had-std? variable or need to get treated, because
                                   ;; assumption made is that having just 1 std will deter the person from having unsafe sex... but this isnt true

monogamy


  ;if Boss-influence? [ talk-to-boss ]
    -- talking to partner is different than just friends, possible different genders of friends too

use the netowrks extension





## NETLOGO FEATURES
n-of is used to split the agent population into two genders evenly.

Breeds are used for the genders of turtles, as well as for distinguishing friend links from sexual partner links.

The random-near function generates many small random numbers and adds them together to determine individual tendencies. This produces an approximately normal distribution of values across the population.




  ;; The initial number of friends that an agent had (num-friends)
  ;; is used as a maximum number of friend links to create
  ;; Otherwise, the agents will keep making way too many friends
  
  ;; and if updating layout is enabled, will keep moving closer,
  ;; and all cluster in middle of screen


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
<experiments>
  <experiment name="test2-infect-1" repetitions="5" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <metric>%infected</metric>
    <metric>%M-infected</metric>
    <metric>%F-infected</metric>
    <metric>avg-safe-sex-likelihood</metric>
    <metric>avg-male-safe-sex-likelihood</metric>
    <metric>avg-attitude</metric>
    <metric>avg-male-attitude</metric>
    <metric>avg-female-attitude</metric>
    <metric>avg-female-safe-sex-likelihood</metric>
    <metric>avg-certainty</metric>
    <metric>avg-male-certainty</metric>
    <metric>avg-female-certainty</metric>
    <metric>avg-justification</metric>
    <metric>avg-male-justification</metric>
    <metric>avg-female-justification</metric>
    <steppedValueSet variable="%-receive-condom-sex-ed" first="10" step="10" last="90"/>
    <steppedValueSet variable="avg-mesosystem-condom-encouragement" first="10" step="10" last="90"/>
    <enumeratedValueSet variable="num-cliques">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="clique-size">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="avg-num-friends">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-butterflies?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="avg-female-condom-intention">
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="avg-male-condom-intention">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="infection-chance">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="symptomatic?">
      <value value="&quot;females-symptomatic?&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-labels?">
      <value value="false"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="infect-1-5cliquesof7-4friends-nobutterflies-femalesymp" repetitions="5" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>%infected</metric>
    <metric>%M-infected</metric>
    <metric>%F-infected</metric>
    <metric>avg-safe-sex-likelihood</metric>
    <metric>avg-male-safe-sex-likelihood</metric>
    <metric>avg-attitude</metric>
    <metric>avg-male-attitude</metric>
    <metric>avg-female-attitude</metric>
    <metric>avg-female-safe-sex-likelihood</metric>
    <metric>avg-certainty</metric>
    <metric>avg-male-certainty</metric>
    <metric>avg-female-certainty</metric>
    <metric>avg-justification</metric>
    <metric>avg-male-justification</metric>
    <metric>avg-female-justification</metric>
    <steppedValueSet variable="%-receive-condom-sex-ed" first="10" step="10" last="90"/>
    <steppedValueSet variable="avg-mesosystem-condom-encouragement" first="10" step="10" last="90"/>
    <enumeratedValueSet variable="num-cliques">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="clique-size">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="avg-num-friends">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-butterflies?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="avg-female-condom-intention">
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="avg-male-condom-intention">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="infection-chance">
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="symptomatic?">
      <value value="&quot;females-symptomatic?&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-labels?">
      <value value="false"/>
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
1
@#$#@#$#@
