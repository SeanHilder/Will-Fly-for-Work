# Person C — Level 1: Zero-G Vet Clinic

**Branch:** `mvp-level1`
**Focus:** the playable minigame. Timed shift, zero-g physics, grab the patient, treat them.

## Setup (from README)

- **Twist:** no gravity — nothing stays still, not the patient, not your tools, not you
- **Mechanic:** click-drag to grab, momentum is real; treatment items float and must be caught
- **Escalation:** more patients drift in, tools scatter, one patient panics and thrashes
- **HR-Bot line:** *"Gravity assist protocols unavailable. This is, statistically, your problem now."*

## Tasks

- [ ] `level_1.tscn` scene — script extends `BaseLevel` from A (`scripts/gameplay/base_level.gd`)
  - [ ] Set `level_id = "level_1"`
- [ ] Zero-g physics:
  - [ ] `PhysicsServer2D` / level gravity = 0, or project-level toggle — ask A for the cleanest spot
  - [ ] Patient + tools are `RigidBody2D` with friction 0 (drift forever)
  - [ ] Walls (StaticBody2D) around the clinic room, slight bounce on impact
- [ ] Patient creature(s) using A's `Grabbable`
  - [ ] Drifts in tumbling at shift start (spawn with random velocity + rotation)
  - [ ] Patient state machine: `idle → thrashing` (thrash = random force impulses, triggers escalation)
- [ ] Treatment items (scanner, medicine, bandage — placeholder sprites OK)
  - [ ] Float free, catchable only by grabbing (not clicking)
  - [ ] Use item on patient while grabbed → progress bar fills → patient treated
- [ ] Shift flow:
  - [ ] `start_shift()` begins the timer (~60–90s), briefing dialog closes first
  - [ ] Task queue: e.g. "treat 3 patients" — each treated patient = score points
  - [ ] Escalation hook: every N seconds, spawn another drifting patient / scatter tools
  - [ ] Timer ends → `end_shift(score)` → `GameManager.level_completed("level_1", score)`
- [ ] Player: reuse the top-down player from A (or a simple placeholder) inside the clinic

## Scoring (agree with D)

- Base points per patient treated, bonus for speed (remaining time)
- Star thresholds (D displays them): e.g. ≥1 treated = 1 star, all treated = 2, fast + all = 3

## Hand off to others

- Tell A about any `Grabbable` API you had to bend so he can fix the contract
- Tell D the exact signal/values: `on_shift_completed(score)` + any stat you track (patients treated, time left)

## Done when

- Level starts after dialog, player can grab the tumbling patient with real momentum
- Treating the patient works end-to-end with a progress fill
- Timer ends the shift, score is reported, fade back to world hub
- Escalation spawns at least one extra patient mid-shift
