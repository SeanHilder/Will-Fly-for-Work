class_name BaseLevel extends Node2D
## BaseLevel — the contract every level scene implements.
##
## A level scene is the minigame the player plays between hub visits. It is
## loaded by GameManager.start_level(level_id), which also sets
## GameManager.current_level_id before the scene switches.
##
## Contract for level authors (Person C):
##   1. Extend this script from your level scene root.
##   2. Set `level_id` to the id registered in GameManager.LEVELS
##      (e.g. "level_1"). If it does not match the level GameManager is
##      running, a warning is printed in _ready.
##   3. Override start_shift() to begin gameplay (spawns, timer, etc.).
##   4. When the shift ends, call end_shift(score) so the HUD and evaluation
##      flow can react. BaseLevel does NOT call GameManager directly — the
##      evaluation screen's "Next" button calls
##      GameManager.level_completed(level_id, score) to record and return to
##      the hub (Person D owns that wiring).
##
## Flow: start_level() -> level scene loads -> briefing dialog ends ->
## start_shift() -> ... gameplay ... -> end_shift(score) ->
## on_shift_completed emitted -> evaluation -> level_completed() -> hub.

## Stable level id, must match an entry in GameManager.LEVELS.
@export var level_id: String = ""

## Nominal shift length in seconds. The level's own timer is the source of
## truth; this is a shared default for HUD display.
@export var shift_duration := 60.0

## Emitted when the shift ends. Listeners: HUD (Person D) and anything that
## reacts to the end of gameplay.
signal on_shift_completed(score: int)

func _ready() -> void:
	if level_id != GameManager.current_level_id:
		push_warning(
			"BaseLevel: this scene is level '%s' but GameManager is running '%s'. "
			% [level_id, GameManager.current_level_id]
		)


## Begin gameplay. Override in the concrete level. Called after the job
## briefing dialog has closed (Person B's world hub triggers the level, the
## level decides when briefing is over — for the MVP stub it starts at once).
func start_shift() -> void:
	pass


## Finish the shift and report the score.
## Emits on_shift_completed(score) so the evaluation flow can start.
## Does not call GameManager.level_completed() — that stays with the
## evaluation "Next" button (Person D) to keep the UI in control of pacing.
func end_shift(score: int) -> void:
	on_shift_completed.emit(score)
