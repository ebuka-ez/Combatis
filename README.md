# Combatis

Combatis is a blockchain-based collectible battle game where players mint, own, and battle unique warriors with varying stats and classes. Each warrior can grow stronger through battles and leveling up, while ownership and battle outcomes are fully recorded on-chain.

---

## Overview

Combatis introduces a decentralized NFT battler system where every warrior has distinct attributes. Players can mint warriors, engage them in duels, and upgrade them over time. Each battle is automatically resolved based on warrior stats, with results recorded immutably for transparency.

---

## Core Features

* On-chain warrior creation with class-based attributes
* Automated battle resolution based on attack and defense power
* Level-up system that increases stats with each upgrade
* Ownership tracking for all minted warriors
* Full battle history storage for replay and validation

---

## Constants

| Constant                | Description                                                    |
| ----------------------- | -------------------------------------------------------------- |
| `ERR-NOT-PERMITTED`     | Raised when an unauthorized user performs a restricted action. |
| `ERR-INVALID-WARRIOR`   | Raised if a warrior ID is invalid or missing.                  |
| `ERR-INSUFFICIENT-STX`  | Raised if a player cannot pay the minting fee.                 |
| `ERR-BATTLE-PROHIBITED` | Raised when a player tries to battle their own warrior.        |

---

## Data Maps

| Map              | Key                  | Description                                                                     |
| ---------------- | -------------------- | ------------------------------------------------------------------------------- |
| `warrior_stats`  | `{warrior_id: uint}` | Stores warrior traits such as name, attack, defense, health, level, and class.  |
| `warrior_owners` | `{warrior_id: uint}` | Tracks ownership of each warrior.                                               |
| `battle_history` | `{battle_id: uint}`  | Records details of every battle including participants, winner, and block time. |

---

## Data Variables

| Variable          | Type | Description                                                    |
| ----------------- | ---- | -------------------------------------------------------------- |
| `mint_price`      | uint | The STX fee required to mint a new warrior (default: 0.1 STX). |
| `warrior_counter` | uint | Next available warrior ID.                                     |
| `warrior_count`   | uint | Total number of warriors minted.                               |

---

## Public Functions

### `mint_warrior (name class)`

Creates a new warrior with base stats determined by its class.
**Fee:** Transfers `mint_price` from the sender to the contract.
**Returns:** `(ok warrior_id)`
**Class-based Base Stats:**

| Class     | Attack | Defense | Description      |
| --------- | ------ | ------- | ---------------- |
| Legendary | 50     | 50      | Top-tier warrior |
| Rare      | 30     | 30      | Strong warrior   |
| Common    | 10     | 10      | Basic warrior    |
| Default   | 20     | 20      | Balanced warrior |

---

### `start_battle (attacker_id defender_id)`

Initiates a battle between two warriors and determines the winner.
**Logic:**

* Retrieves each warrior’s attack and defense stats
* Prevents self-battles between the same owner
* Declares the winner based on higher attack or defense values
* Records the battle in history

**Returns:** `(ok winner_id)`

---

### `level_up_warrior (warrior_id)`

Allows a warrior’s owner to increase its stats.
**Effects:**

* Attack +5
* Defense +5
* Health +10
* Level +1

**Access:** Owner only
**Returns:** `(ok true)`

---

## Read-Only Functions

| Function                         | Description                                                  |
| -------------------------------- | ------------------------------------------------------------ |
| `get-warrior-stats (warrior_id)` | Returns warrior attributes including name, stats, and class. |
| `get-warrior-owner (warrior_id)` | Returns the principal that owns a given warrior.             |

---

## Battle History Tracking

Every recorded battle includes:

* `attacker_id`
* `defender_id`
* `winner_id`
* `block_time`

This enables transparent recordkeeping of all combat outcomes.

---

## Initialization

When deployed, the contract initializes with:

* `mint_price` = 0.1 STX
* `warrior_counter` = 1
* `warrior_count` = 0

---

## Summary

Combatis provides an interactive framework for NFT-based battling where every mint, upgrade, and duel is stored immutably on-chain. It merges collectible ownership mechanics with transparent, rule-driven combat, offering a foundation for play-to-earn or PvP expansion.
