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

  avg-relationship-length ;; Average number of ticks a sexual partnership/couple will stay together (commitment)
  
  
  certainty-delta ;; the amount that certainty increases
                  ;; whenever an agent repeats their attitude to others
                  ;; as certainty increases, it becomes harder to change an agent's opinion
  
  justification-delta ;; the amount that justification decreases
                      ;; every time an agent thinks they "got away" with unsafe sex
 
]


;;; --------------------------------------------------------------------- ;;;
;;;
;;; Turtle/Agent Variables
;;;
;;; --------------------------------------------------------------------- ;;;

turtles-own
[
  ;; The percent chance a person uses protection (condoms) while in a couple
  ;; The likelihood (0 - 100%) of this agent practicing safe sex (reflects behavior)
  ;; Likelihood is influenced by three components:
  ;; attitude, certainty, and justification

  safe-sex-likelihood

  ;; Variable used to determine how much this agent's safe sex likelihood
  ;; has changed since the last tick
  old-safe-sex-likelihood 
  
  ;; ATTITUDE:
  ;; The intention or desire of an agent to practice safe sex (use a condom)
  ;; Evolves over time through talking to peers, or becoming infected
  attitude 
                 
  
  ;; CERTAINTY:
  ;; how confidently/strongly an agent feels about their attitude
  ;; The chance that an attitude changes is inversely proportional to certainty
  certainty ;; initially set to mesosystem-condom-encouragement
            ;; i.e. how much their upbringing encouraged safe sex
            ;; might consist of parents' beliefs, life experiences, religious attitudes, etc.
  
  
  ;; JUSTIFICATION:
  ;; the logic or reasoning to rationalize having a postive attitude towards safe sex,
  ;; which is independent of how strongly they feel about it (certainty)
  ;; or what their actual attitude is
  justification ;; initially set to the level of accurate education this agent has about safe sex and condom usage
  
  
  had-unsafe-sex? ;; Whether this person had sex without a condom on the last tick
  
  infected? ;; If true, the person is infected (and infectious)
  known?    ;; The person is infected and knows it (due to being symptomatic)
  ;; In this model, agents that know they are infected
  ;; always use condoms to protect their sexual partners
  ;; If an agent is not symptomatic/of a symptomatic gender,
  ;; their known? variable never gets set to true, which 
  ;; may enable an STI to more easily spread through a population
  
  coupled?      ;; If true, the person is in a sexually active couple.
  partner       ;; The person that is our current partner in a couple.
  couple-length ;; How long the person has been in a couple.
  
  friendship-tendency ;; How likely this person is to make a new friend
  coupling-tendency   ;; How likely the person is to join a couple.
  commitment          ;; How long the person will stay in a couple/relationship.
  
  group-membership ;; which clique/friend group/cluster this agent is part of
  
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
  
  ;; By default, setup infects two random individuals in the model with an STI
  ;; but if you want to also explore spread of attitudes without an STI spreading
  ;; through the population, comment out the line below

  infect-random ;; infect one random male and one random female

               
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
  
  ;; the amount certainty increases when an agent repeats their attitude
  set certainty-delta .1 
  
  ;; the amount justification decreases when an agent thinks they "got away with" unsafe sex
  set justification-delta 2
  
  ;; These could also be set in assign-sex-ed-level
  set no-condom-sex-ed-level 20
  set condom-sex-ed-level 80
  
  ;; Call functions to set whether females and males show symptoms of the STI
  ;; based on value of chooser/drop-down in interface
  run word "set-" symptomatic?
  
  ;; For simplicity, use predetermined values to set these variables
  ;; (compared to AIDS model, which uses sliders) 
  
  set max-friendship-factor 70
  set max-coupling-factor 40
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
  ; The - 1 accounts for each member initially linking to the leader
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
    
    
    ;; Determine how much this agent's likelihood of practicing safe sex
    ;; has changed since last tick.
    ;; (If likelihoods of all agents stop changing significantly,
    ;; the simulation will stop.)
    update-safe-sex-likelihood
    set old-safe-sex-likelihood safe-sex-likelihood
    
    
    assign-turtle-color ;; Color is determined by likelihood of practicing safe sex
    assign-shape        ;; Shape is determined by gender and sick status
    set size 2.5        ;; Make shapes a bit easier to distinguish by increasing size
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
to assign-normally-distributed-member-variables ;; turtle procedure
  
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
    ;; and being aware of contracting an STI
    ifelse (is-female? self)
    [ set attitude random-near avg-female-condom-intention ]
    [ set attitude random-near avg-male-condom-intention ]
    
    ;; Assign initial certainty based on mesosystem encouragement
    ;; Certainty increases whenever an agent repeats their attitude to others
    ;; Currently, certainty does not decrease in this model
    set certainty random-near avg-mesosystem-condom-encouragement
    
    ;; Assign initial justification based on sex ed agent received
    ;; Justification can decrease if agent thinks they "got away with" having unsafe sex
    ;; or increase if they contract an STI themselves
    ;; Note: in this model, the justification is not justification for
    ;; the attitude itself, but rather a justification for having safe sex
    assign-sex-ed-level

end

;;
;; Assign a level of accurate knowledge of safe sex
;; normally distributed around a high or low value
;; based on type of sex ed the agent received.
;; Used to initialize the agent's justification.
;;
to assign-sex-ed-level ;; turtle procedure
  
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
;; Color of the agent reflects their individual 
;; likelihood of practicing safe sex
;;
to assign-turtle-color ;; turtle procedure
  
  ;; call this just in case a variable went out of accepted range
  cap-member-variables 
 
  ;06C106 green - 100% likely to engage in safe sex (using a condom)
  ;FFFFFF white - 50% likely of having safe sex 
  ;C10606   red  - 0% likely to use a condom (100% likely to have unsafe sex)
 
  ;; If there was a switch statement for NetLogo,
  ;; this would be where you'd use it
  if (safe-sex-likelihood >= 0) [ set color [ 193   6   6 ] ] ;; 0-5 % - red
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
    
  set thickness .16 ; make the link a bit easier to see
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
  
  ;; If all agents reach a polarized safe-sex-likelihood,
  ;; or all agents are certain of their attitude (will not change any more)
  ;; the model has reached a stable state, so stop
  if all? turtles [
    safe-sex-likelihood < 0.1 or
    safe-sex-likelihood > 99.9 or
    certainty > 99.9
    ] [stop]
 
 
  ;; record each agent's likelihood before interacting with others,
  ;; and potentially getting/realizing they are infected 
  ask turtles [ set old-safe-sex-likelihood safe-sex-likelihood ]
  
  ask turtles
  [
    ;; Agents talk to their friends and sexual partner (if any), which
    ;; might impact his/her personal likelihood of practicing safe sex
    talk-to-peers
    
    ;; If already coupled with a sexual partner,
    ;; just increase length of relationship
    ;; (agents are monogamous in this simulation)
    ifelse coupled? [ set couple-length couple-length + 1 ]
    
    ;; If they are NOT coupled, agent tries to find a mate
 
    ;; Any agent can initiate mating if they are not coupled
    ;; (and random chance permits)
    [ if (random-float max-coupling-factor < coupling-tendency) [ couple ] ]
  ]
  
  ;; give everyone (coupled or not) a chance to make a friend
  ask turtles
  [
    ;; Everyone should attempt to make friends because otherwise,
    ;; the sexual partner links break and agents end up 
    ;; only being friends with agents of the same sex
    
    ;; If this agent has not reached their maximum limit of friends,
    ;; try to make a friend / create a friend link
    if ( (count friend-neighbors < num-friends) and
         random-float max-friendship-factor < friendship-tendency )
    [ make-friends ]
    
    ;; If this agent already has reached their maximum limit of friends,
    ;; don't try to create any more friend links
  ]
  
  ;; Agents will uncouple if the length of the relationship reaches
  ;; the commitment threshold for one of the partners
  ;; Call uncouple after make-friends and couple, 
  ;; because you wouldn't want exes immediately friending each other again,
  ;; and this model doesn't simulate instant rebounds
  ask turtles [ uncouple ]
  
  ;; If turtles are coupled (have a sexual partner), 
  ;; they will have sex on each tick, and have the potential
  ;; of spreading an STI if they have unprotected sex.
  ask turtles [ have-sex ]
  
  ;; In order to best simulate that STIs may not present symptoms immediately,
  ;; don't check if infected (known determined by being symptomatic)
  ;; until after talking to friends about attitude and having sex
  ask turtles [ check-infected ]
  
  ask turtles
  [ 
    update-safe-sex-likelihood
    assign-turtle-color ;; based on safe-sex-likelihood
  ]

  tick
end


;;; --------------------------------------------------------------------- ;;;
;;
;; Update the likelihood (out of 100) that an agent
;; will practice safe sex (use a condom).
;;
to update-safe-sex-likelihood
  
  ;; The likelihood of an agent engaging in safe sex behaviors (using a condom)
  ;; is determined by a combination of the agent's:
  ;;   - attitude (desire)
  ;;   - justification (knowledgeable background/logical reasoning for safe sex attitude)
  
  ;; Certainty is assumed to be independent of attitude value itself,
  ;; even when the attitude is polarized (close to 100 or close to 0)
  ;; Certainty impacts how resistant an agent is to change their attitude
  ;; when talking to others, and how many others the agent interacts with,
  ;; but doesn't directly impact likelihood calculation.

  ;; cap variables just in case
  cap-member-variables ; make sure no variables got set to < 0 or > 100
  
  ;; Likelihood is strongly weighted by attitude
  let attitude-weight .75
  let justification-weight .25
  
  set safe-sex-likelihood (attitude * attitude-weight + justification * justification-weight)

end


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
  
  ;; Use certainty to determine how many links this agent talks to per tick
  ;; The more certain a person is in their attitude,
  ;; the more likely they are to discuss it with their peers/links.
  
  let convoCount 0
  
  ;; NOTE: These "conversations"/"interactions" are one-directional in this model.
  ;; Additionally, an agent is not guaranteed to talk to their sexual partner
  while [ convoCount < ( certainty / 100 ) * ( count my-links ) ] 
  [
      
      let peer one-of link-neighbors ;; friends or sexual partner, if any
      if (peer != nobody)
      [
        ;; An agent grows more certain of their attitude
        ;; (regardless of what that attitude actually is)
        ;; every time they express it to someone else (repeated expression)
          
        set certainty certainty + certainty-delta
        
        
        ;; A person's certainty impacts how likely they are to change their attitude.
        ;; An agent with higher certainty is more resistant to changing their attitude.
        ;; (100 - certainty) is how likely an agent is to adjust their attitude.
        
        let attitude-change-chance ( (100 - certainty) / 100 )
        

        ;; However, an agent doesn't care about how confident their peer
        ;; feels about his/her attitude (their certainty), s/he only cares about
        ;; what reasoning they have to back up their attitude (justification).
        ;; So if the peer has strong justification of their attitude, 
        ;; the agent is more likely to be swayed
        
        let peer-persuasion-chance ( [justification] of peer / 100 )
        
        
        ;; Constants for dampening and getting desired reactions
        ;; calculated through tinkering with Excel formulas
        let scale-factor 10 
        let c 0.5
        
          
        ;; In order to account for polarity/extremity of attitude
        ;; subtract 50 from it to aid in the calculations
        ;; So "your" (this agent's) attitude scaled down to be between
            ;; -50 (very anti safe sex)
            ;; to 0 (neutral)
            ;; to 50 (very pro safe sex)   
            
        let my-attitude-scaled ( (attitude - 50) / scale-factor )
        let peer-attitude-scaled ( ([attitude] of peer - 50) / scale-factor )
        let temp-var ( my-attitude-scaled * my-attitude-scaled * peer-attitude-scaled / (scale-factor ^ 3) ) 
        
        let attitude-change ( c * attitude-change-chance * peer-persuasion-chance * temp-var)
        
        set attitude attitude + attitude-change
      ]
      
      set convoCount convoCount + 1
  ]
  
    ;; update personal likelihood based on talking to peers
    update-safe-sex-likelihood 
  
end


;;; --------------------------------------------------------------------- ;;;
;;;
;;; SPREAD STI (potentially) / HAVE SEX
;;;
;;; --------------------------------------------------------------------- ;;;

;;
;; Only agents with sexual partners (coupled) can spread an STI
;;
;;
to have-sex ;; turtle procedure (only for coupled turtles)
  
  
  ask turtles with [coupled?]
  [
    ;; Infection can occur if either person is infected, but the infection is unknown.
    ;; This model assumes that people with known infections will continue to couple,
    ;; but will always practice safe sex.

    ;; This model simulates sexual relations between a male and a female,
    ;; so I decided that only one of the partner's desire to use a condom
    ;; must be strong enough to make sure the couple has safe sex.
    
    ;; Extensions/modifications may choose to change this so that
    ;; for condom use to occur, BOTH people must want to use one.
    ;; This can be done by changing the primitive after the
    ;; second grouped condition of the ifelse statement from AND to OR

    ifelse ( (not known? and [not known?] of partner) and
             (random-float 100 > safe-sex-likelihood) AND   ;; Optional: change this to or for both people to have to want to use a condom
             (random-float 100 > ([safe-sex-likelihood] of partner))
           ) 
    [
      ;; If got past the above conditional, that means the couple had unprotected sex
      set had-unsafe-sex? true
      ask partner [ set had-unsafe-sex? true ]
      
      ;; They had unprotected sex, so infection is possible...
      if (random-float 100 < infection-chance)
      [
        ;; Spread virus between an infected and non-infected coupled partner duo
        if (infected?) [ ask partner [ become-infected ] ]
        if ([infected?] of partner) [ become-infected ]
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
;; Agents might couple depending on their gender, their tendency to couple,
;; and if they are already friends/in same clique/nearby a potential single mate
;;
;; ----- Try to find a valid partner ----- ;;
;; 1) try existing friend link of opposite sex
;; 2) try opposite sex within friend group, but not a current link
;; 3) try a nearby opposite sex person as a last resort
;; (probability of successful coupling decreases for last 2 options)
;;
to couple ;; turtle procedure (single turtles only)
  ;; all my single turtles, now put your hands UP
  
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
to uncouple ;; turtle procedure (coupled turtles only)
  if coupled?
  [
    if (couple-length > commitment) or
      ([couple-length] of partner) > ([commitment] of partner)
      [
        ;; Break the link between these two turtles
        ;; assume they don't go back to being friends
        ask sexual-partner-with partner [die]
        
        ;; but if you wanted them to "just be friends"... uncomment line below
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
  infect-random-female
  infect-random-male
  ;if (count turtles > 1)
  ;[
  ;  ask n-of 1 turtles with [not infected?]
  ;  [ become-infected ]
  ;]
end


to infect-random-female
  if (count females > 1)
  [
    ask n-of 1 females with [not infected?]
    [ become-infected ]
  ]
end

to infect-random-male
  if (count males > 1)
  [
    ask n-of 1 males with [not infected?]
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
;; Ideally don't want check-infect and become-infected happening on same tick
;; --> not realistic, std symptoms don't instantly show up
;; Otherwise, if not symptomatic, don't change their known? variable
;;

to check-infected
 
  ;; Justification decreases when an agent thinks they had unsafe sex 
  ;; and observes no negative consequences (i.e. didn't contract an STI,
  ;; or doesn't feel symptoms, regardless of whether s/he is actually infected).
  
  if ( had-unsafe-sex? and ( not infected? or
     (is-male? self and not males-symptomatic?) or
     (is-female? self and not females-symptomatic?) )
     )
  [ set justification (justification - justification-delta) ]

    
  ;; If an agent is infected and realizes it (due to being symptomatic)
  ;; Their likelihood of practicing safe sex increases significantly,
  ;; since we assume that agents are not malicious and intentionally infecting others
  
  if ((infected? and not known?) and
    ((is-male? self and males-symptomatic?) or
    (is-female? self and females-symptomatic?)))
  [
    set known? true
    set justification 100 ;; after getting an std, turtles always want to have safe sex - logical reason
    ;; direct experience is always more powerful at changing attitude than just talking about it
    set attitude 100 ;; also set their attitude towards safe sex to 100% positive
  ]
  
  update-safe-sex-likelihood 
  assign-turtle-color
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


;; --------------- Change in likelihood between ticks --------------- ;;

;; Note: take absolute value, otherwise if some turtles are
;; very positively increasing and others are very negatively decreasing,
;; could result in calculating like there is no change occurring
to-report avg-likelihood-change
  report mean [ abs (safe-sex-likelihood - old-safe-sex-likelihood)] of turtles
end

to-report avg-male-likelihood-change
  report mean [abs (safe-sex-likelihood - old-safe-sex-likelihood)] of males
end

to-report avg-female-likelihood-change
  report mean [abs (safe-sex-likelihood - old-safe-sex-likelihood)] of females
end

;; originally used above measures for a plot,
;; but it wasn't very interesting given the space it took up


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
615
10
1009
425
15
15
12.4
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
430
290
575
323
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

PLOT
790
430
1010
595
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

BUTTON
415
250
485
283
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
420
230
580
248
Select a person to have an STI
11
0.0
1

TEXTBOX
40
230
345
275
Certainty: How confident an agent feels in their atittude.\nMay be influenced by parental involvement, religious background, etc.
11
0.0
1

BUTTON
490
250
585
283
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
415
175
580
220
symptomatic?
symptomatic?
"males-symptomatic?" "females-symptomatic?" "both-symptomatic?" "neither-symptomatic?"
0

SLIDER
15
30
165
63
num-cliques
num-cliques
1
20
6
1
1
NIL
HORIZONTAL

SLIDER
330
30
470
63
avg-num-friends
avg-num-friends
2
clique-size - 1
7
1
1
NIL
HORIZONTAL

SLIDER
415
135
580
168
infection-chance
infection-chance
0
100
45
1
1
NIL
HORIZONTAL

SLIDER
170
30
325
63
clique-size
clique-size
2
35
10
1
1
people
HORIZONTAL

BUTTON
430
330
500
370
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
505
330
575
370
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
40
155
250
188
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
40
190
250
223
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
40
275
315
308
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
40
140
280
158
Attitude: Intention/desire to use a condom
11
0.0
1

TEXTBOX
450
110
585
128
STI characteristics
11
0.0
1

PLOT
315
430
545
595
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
15
10
480
28
Parameters to initialize a social network, consisting of discrete social groups (cliques).
11
0.0
1

TEXTBOX
40
310
350
385
Justification: The level of logical reasoning an agent has to rationalize their attitude towards safe sex.\nReceiving sex ed including condom usage increases accurate knowledge about safe sex practices and benefits.
11
0.0
1

SWITCH
15
70
165
103
social-butterflies?
social-butterflies?
1
1
-1000

PLOT
5
430
310
595
Safe Sex Likelihood Components
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
"M Attitude" 1.0 0 -13791810 true "" "plot avg-male-attitude"
"M Certainty" 1.0 0 -13345367 true "" "plot avg-male-certainty"
"M Justification" 1.0 0 -11221820 true "" "plot avg-male-justification"
"F Attitude" 1.0 0 -5825686 true "" "plot avg-female-attitude"
"F Certainty" 1.0 0 -2674135 true "" "plot avg-female-certainty"
"F Justification" 1.0 0 -2064490 true "" "plot avg-female-justification"

SLIDER
40
385
257
418
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
445
385
570
418
show-labels?
show-labels?
0
1
-1000

TEXTBOX
170
70
430
100
Enable to initialize a limited number of inter-group links between \"clique leaders\".
11
0.0
1

PLOT
550
430
785
595
Safe Sex Likelihood Histogram
likelihood
# agents
0.0
100.0
0.0
25.0
true
true
"set-plot-y-range 0 (count turtles / 2.5)" ""
PENS
"M" 10.0 1 -13345367 true "" "histogram [safe-sex-likelihood] of males"
"F" 10.0 1 -2064490 true "" "histogram [safe-sex-likelihood] of females"

TEXTBOX
65
115
260
133
Safe Sex Likelihood Components
11
0.0
1

TEXTBOX
280
390
445
425
Shows the exact likelihood of an agent engaging in safe sex.
11
0.0
1

@#$#@#$#@
## WHAT IS IT?

This model aims to simulate the spread and development of safe sex attitudes and behaviors in response to the prevalence of a sexually transmitted infection (STI) throughout a social network of young adults. It also takes into account how these variables influence one another and change over time using theories of attitude change and certainty.


## HOW IT WORKS

The NetLogo model is organized as a social network of agents arranged as mostly discrete social circles, with some (optional) central agents (“social butterflies”) that have links to central members of other social groups in addition to links to all members in their clique. Agents start with a certain number of friendship links (limited to between others in their clique), and no sexual partner links. Friend links are gender independent, but sexual partners are not – they require a coupling of one male and one female agent. Individual agent variables are assigned randomly following a normal distribution based on slider or global values.

The model initiates by having one male and one female agent contract a sexually transmitted infection (an STI). The model continues to run until a stop condition is met. Agents are characterized by three variables, Attitude, Certainty and Justification. Likelihood of practicing safe sex is a function of Attitude and Justification. Attitude is in turn a function of Certainty and Justification.


On each tick:

-- **Agents interact with their peers about Attitudes towards safe sex.**

  * Agents talk to their friends and sexual partner, and update their Attitude about practicing safe sex
  * The number of friends the agents talk to is based on their Certainty at a given tick
  * Agents compare their own Attitude and their friend’s Attitude, which will influence the magnitude and sign of the change of Attitude at each tick
  * Agents check their Certainty and their friend’s Justification, which will also influence the magnitude and sign of the change of Attitude at each tick
  * The change in Attitude is used to update each agent’s Attitude to its new state
  * Certainty and Justification are updated 


-- **Agents look for a sexual partner (male-female coupling).**

  * If an agent is NOT coupled, s/he might try to find another single agent of the opposite gender to form a sexual partnership with. Any agent can initiate coupling if they are not coupled and random chance permits (based on their personal/individual coupling tendency). 
  * A hierarchy of coupling preference exists:  The probability of successfully coupling decreases for each of these types of potential partners:
    * First agents look at existing friends of the opposite sex;
    * If they have none, then they choose a person of the opposite sex within their friend group;
    * If there isn’t one, then they resort to choosing the closest non-linked opposite sex agent.
    * If both partners are willing to become a couple, they form a sexual‑partner link (if the two agents were previously friends, this destroys their friendship link).
  * If they are already coupled with a sexual partner, the two agents just increase length of their relationship (agents are monogamous in this simulation).


-- **Agents make friends. **

  * Any agent can initiate “friending” with any other agent (independent of gender) if they (and the potential friend) have not reached their maximum limit of friends and random chance permits (based on their personal/individual friendship tendency).
  * A hierarchy of friending is assumed. The probability of successfully becoming friends decreases for each of these types of potential friends:
    * First agents look at agents within their friend group that they are not currently friends with;
    * If there isn’t one, then they resort to choosing the closest non-linked agent.
    * If both partners are willing to become friends, they form a [blue] friendship link.


-- **Agents that (currently) have a sexual partner can potentially uncouple. Agents will uncouple if the length of the relationship reaches the commitment threshold for one of the partners.**

  * The order in which these functions are called on each tick (uncouple after making friends and couple) helps restrict who can couple after uncoupling, simulating that exes would not be immediately friending each other again; this model does not (intend to) simulate instant rebounds.


-- **If agents are coupled (have a sexual partner), they have sex.**

  * The likelihood that the couple will engage in safe sex (choose to use a condom) depends on a function of the likelihood of both participants.
  * If one of the partners is infected and the couple has unprotected sex, there is a chance that they will spread the disease to them/the other partner will become infected (based on the infectiousness/infectivity of the disease). An infected agent is distinguished by a dot on their shape. 


-- **Agents check if they are infected. Only agents of genders that are symptomatic will know they are infected.**

  * If an agent knows s/he is infected, s/he will always want to practice safe sex for the rest of the simulation. 
  * If an agent has unsafe sex and does not notice any consequences (either is not infected, or is not symptomatic, regardless of infection status), that agent’s likelihood of practicing/inclination to practice safe sex will decrease. 


Agents do not move (i.e., network is fixed) to allow the viewer to observe the spread of disease easier (a concession to unrealism to improve program clarity). 


## HOW TO USE IT

Using the sliders, choose the number of social groups (NUM-CLIQUES) to create and how many people should make up each social group (CLIQUE-SIZE). The agents within the clique are only connected to others within their social group, and will have about AVG-NUM-LINKS "friends", that they are connected to via a blue link. One of these links will be to the central "leader" of the clique. This "leader" is identical to other agents, except it additionally has links to all other clique "leaders", which helps set up a visual layout and generates a very loosely connected social network containing mostly discrete clusters.

Whether a central "clique leader" should have links to leaders of other cliques. Initializes limited links between groups, otherwise there are none on setup.


The SETUP button generates this network and assigns unique values to each individual, based on a normal distribution centered around the average values indicated by the sliders AVG-MESOSYSTEM-CONDOM-ENCOURAGEMENT and AVG-MALE-CONDOM-INTENTION/AVG-FEMALE-CONDOM-INTENTION (depends on agent's gender),as well as setting other variables that are not visible to the user in the same fashion (e.g. tendency to make a friend or sexual partner, maximum length of time willing to spend coupled with a sexual partner).

SETUP will infect one male and one female in the population by default. If the user wants to infect another agent, they can do so through pressing the SELECT button and clicking on an agent, or pressing INFECT-RANDOM. This can also be done while the model is running.

An infected person is denoted with the addition of a dot on their body, and they will have a INFECTION-CHANCE chance of infecting a partner during unprotected sex. If they are of a gender that is symptomatic of the STI (set by the SYMPTOMATIC? chooser), they are aware of their infected status, the dot will be white, and the agent will adjust their attitude and safe sex likelihood to automatically practice safe sex to protect his or her partners. However, if the agent is not a gender that is symptomatic, the dot will appear black, they will be oblivious to their infected state, and continue their normal likelihood of practicing safe sex.

The model stops when the entire population is infected, if all agents reach 100% certainty in their attitude, or if all agents have reached a single, unchanging safe-sex-attitude of either 0 or 100.


### Simplifying assumptions

This model only simulates heterosexual/heteronormative, college-aged young adults - both male and female. Agents in the simulation can only have a maximum of one partner at a time. The complexities of different types of sexual behaviors (abstinence, long-term monogamy, or strictly hook-ups) are not included in the model.
 
Although STIs may be transmitted through avenues other than sexual behavior, as in drug needles, childbirth, or breastfeeding, this model focuses on the sexual interactions, as they are most common form of transmission - especially in the age demographic in question. Additionally, although there are forms of protection against STIs/STDs other than condoms, it is the form of sexual protection that is most prevalent and accessible for the demographic of interest.

Although some members of the cliques have or develop links to agents in other groups, the social groups are generated at the beginning of the simulation and remain fairly static. Agents cannot change group affiliation over time, and are not able to be part of more than one social group at a time.


## THINGS TO NOTICE

Set one of the genders to not be symptomatic. What happens to their justification, in comparison to the other gender? What trends happen to their attitude and safe sex likelihood overall?

Occasionally, there will be an agent that forms a very different likelihood for safe sex than that that of his or her clique, and seemingly refuses to change his or her mind.  (This becomes obvious, since color is used to indicate an individual's safe sex likelihood.) Why does this happen? What circumstances or agent characteristics seem to make this event more likely to happen?


## THINGS TO TRY

By default, 2 agents in the population are infected - 1 male and 1 female. Under what conditions can the spread of infection be minimized?

By adjusting the parameters, is it possible to have every agent in the simulation colored very green, i.e. have a safe sex likelihood near 100%? Can you adjust the parameters so that every agent in the simulation colored very red, i.e. have a safe sex likelihood near 0%? Can both of these outcomes be accomplished without the infection spreading significantly? 

Can the model variables be adjusted (specifically those relating to the social networks) be adjusted so that members of some cliques form safe sex likelihoods that are significantly different from those of other cliques? Is the safe sex likelihood of clique members (which is influenced by agent attitudes and interactions with one another) dependent on one of the members becoming aware of contracting an STI?


## EXTENDING THE MODEL

Condom use for the purpose of protection against sexually transmitted diseases (vs. just for pregnancy prevention) increased when fear of HIV/AIDS was prevalent in the media in the late 80's and early 90's. Incorporate an element of media influence that impacts the behaviors of the agents in some way.

Relationships that involve sexual partners are more complex in nature than as they are represented in this model. (In the existing functionality, single agents are constantly looking for sexual partners, and coupled agents are always having sex.) For instance, some couples are strictly monogamous, or some individuals choose to be abstinent, which greatly lowers the risk of contracting a sexually transmitted infection. Between sexually active couples, condom usage may vary, or other forms of protection may be used. Additionally, condoms are not always a fully effective form of protection: they are often not properly used, or may be used for some sexual acts, but not others, which still presents a risk of spreading an STI. Extend the model to attempt to account for some of the complex behaviors and infection risks surrounding sexual partnerships. For example, some individuals might refuse to have unprotected sex, which might potentially cause tension between the couple, or even prompt them to break up. 

In this model, agents are assumed to be willing to talk about their attitude, certainty, and justification regarding safe sex with their peers. Given the private nature of this topic, this may not be the case. It is probably more likely that safe sex will be discussed with potential sexual partners, so extend the model to increase the likelihood of discussing safe sex with partners, and optionally increase the potential influence of these interactions on an individual's safe sex attitude, certainty, and/or justification. Additionally, implement a mechanism that makes agents more or less likely to share their thoughts about safe sex with friends. Optionally, include gender in this mechanism - e.g., same-sex friends are more likely to discuss sexual health with one another, or one gender is more likely to discuss safe sex in general.

Use the [Networks NetLogo extension] (https://github.com/NetLogo/NW-Extension) to create and analyze a more complex and realistic social network. 


## NETLOGO FEATURES

Breeds are used for the genders of turtles, as well as for distinguishing friend links from sexual partner links.

n-of is used to split the agent population into two genders evenly.

The random-near function generates many small random numbers and adds them together to determine individual tendencies. This produces an approximately normal distribution of values across the population.

Since NetLogo does not have an equivalent of a switch statement currently, an extremely long list of if statements in the assign-turtle-color function was used.


## RELATED MODELS
Virus
AIDS
Disease Solo
Virus on a Network


## CREDITS AND REFERENCES

NetLogo Models not from the Models Library:
STI model (Lizz Bartos & Landon Basham for LS 426, Winter 2013)
[Sophia Sullivan Final Project for EECS372 Spring 11] (http://modelingcommons.org/browse/one_model/3023)



TODO....

For non-Netlogo models that are related, put links or citations in the CREDITS AND REFERENCES section.


CREDITS AND REFERENCES
If the model is based on published sources (or web sites), it's good to include the reference (or URL) information here.
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
  <experiment name="initial-certainty-vs-intial-justification-impact" repetitions="5" runMetricsEveryStep="true">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="1000"/>
    <metric>avg-safe-sex-likelihood</metric>
    <metric>avg-male-safe-sex-likelihood</metric>
    <metric>avg-female-safe-sex-likelihood</metric>
    <metric>%infected</metric>
    <metric>%M-infected</metric>
    <metric>%F-infected</metric>
    <metric>avg-male-attitude</metric>
    <metric>avg-female-attitude</metric>
    <enumeratedValueSet variable="symptomatic?">
      <value value="&quot;males-symptomatic?&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="infection-chance">
      <value value="45"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="social-butterflies?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="avg-male-condom-intention">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="avg-female-condom-intention">
      <value value="80"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-cliques">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="clique-size">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="avg-num-friends">
      <value value="7"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="show-labels?">
      <value value="true"/>
    </enumeratedValueSet>
    <steppedValueSet variable="avg-mesosystem-condom-encouragement" first="10" step="10" last="90"/>
    <steppedValueSet variable="%-receive-condom-sex-ed" first="12" step="10" last="82"/>
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
