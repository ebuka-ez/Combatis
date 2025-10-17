;; Crypto Collectible Battler NFT Smart Contract

;; Constants for contract errors
(define-constant ERR-UNAUTHORIZED (err u100))
(define-constant ERR-INVALID-CHARACTER (err u101))
(define-constant ERR-LOW-BALANCE (err u102))
(define-constant ERR-SELF-BATTLE-BLOCKED (err u103))

;; Character traits structure
(define-map character_attributes 
 {character_id: uint} 
 {
   name: (string-ascii 50),
   attack: uint,
   defense: uint, 
   health: uint,
   level: uint,
   class: (string-ascii 20)
 }
)

;; Track character ownership  
(define-map character_owners
 {character_id: uint}
 {owner: principal}
)

;; Battle history tracking
(define-map combat_records
 {combat_id: uint}
 {
   aggressor_id: uint,
   target_id: uint,
   victor_id: uint, 
   block_height_recorded: uint
 }
)

;; Minting fee and next character ID
(define-data-var creation_fee uint u10000000) ;; 0.1 STX
(define-data-var character_counter uint u1)
(define-data-var total_characters uint u0)

;; Character Creation Function
(define-public (create_character
 (name (string-ascii 50))
 (class (string-ascii 20)) 
)
 (let (
   (character_id (var-get character_counter))
   (initial_attack (if (is-eq class "legendary") u50
                 (if (is-eq class "rare") u30
                   (if (is-eq class "common") u10 u20))))
   (initial_defense (if (is-eq class "legendary") u50
                  (if (is-eq class "rare") u30
                    (if (is-eq class "common") u10 u20))))
 )
   ;; Require minting fee
   (try! (stx-transfer? (var-get creation_fee) tx-sender (as-contract tx-sender)))

   ;; Create character in map
   (map-set character_attributes
     {character_id: character_id}
     {
       name: name,
       attack: initial_attack,
       defense: initial_defense, 
       health: u100,
       level: u1,
       class: class
     }
   )

   ;; Set character owner
   (map-set character_owners
     {character_id: character_id}
     {owner: tx-sender}
   )

   ;; Increment tracking variables
   (var-set character_counter (+ character_id u1))
   (var-set total_characters (+ (var-get total_characters) u1))

   (ok character_id)
))

;; Battle Function
(define-public (initiate_combat
 (aggressor_id uint)
 (target_id uint)
)
 (let (
   (aggressor_owner (unwrap!
     (get-character-owner aggressor_id)
     (err ERR-INVALID-CHARACTER)
   ))
   (target_owner (unwrap!
     (get-character-owner target_id)
     (err ERR-INVALID-CHARACTER)
   ))
   (aggressor_stats (unwrap!
     (get-character-attributes aggressor_id)
     (err ERR-INVALID-CHARACTER)
   ))
   (target_stats (unwrap!
     (get-character-attributes target_id)
     (err ERR-INVALID-CHARACTER)
   ))
   (aggressor_power (get attack aggressor_stats))
   (target_power (get defense target_stats))
   (victor_id (if (> aggressor_power target_power)
                 aggressor_id
                 target_id))
 )
   ;; Prevent battling own characters
   (asserts! (not (is-eq aggressor_owner target_owner))
     (err ERR-SELF-BATTLE-BLOCKED))

   ;; Record battle in history
   (map-set combat_records
     {combat_id: (var-get character_counter)}
     {
       aggressor_id: aggressor_id,
       target_id: target_id,
       victor_id: victor_id,
       block_height_recorded: block-height
     }
   )

   (ok victor_id)
))

;; Character Level Up Function
(define-public (advance_character (character_id uint))
 (let (
   (character (unwrap!
     (get-character-attributes character_id)
     (err ERR-INVALID-CHARACTER)
   ))
   (owner (unwrap!
     (get-character-owner character_id)
     (err ERR-INVALID-CHARACTER)
   ))
 )
   ;; Only owner can level up
   (asserts! (is-eq tx-sender owner) (err ERR-UNAUTHORIZED))

   ;; Increase character stats
   (map-set character_attributes
     {character_id: character_id}
     (merge character {
       attack: (+ (get attack character) u5),
       defense: (+ (get defense character) u5),
       health: (+ (get health character) u10),
       level: (+ (get level character) u1)
     })
   )

   (ok true)
))

;; Read-only Functions for Character Details
(define-read-only (get-character-attributes (character_id uint))
 (map-get? character_attributes {character_id: character_id})
)

(define-read-only (get-character-owner (character_id uint))
 (get owner (map-get? character_owners {character_id: character_id}))
)

;; Initialize the contract
(begin 
 (var-set creation_fee u10000000)  ;; 0.1 STX initial mint fee
 (var-set character_counter u1)
 (var-set total_characters u0)
)