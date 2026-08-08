extends Node
## GameManager — global game-flow / progression autoload.
##
## Owns everything that spans scenes:
##   - the level registry (level_id -> scene path)
##   - sequential level unlocking
##   - the flow: main menu -> world hub -> level -> evaluation -> world hub
##
## Talk to this node ONLY through the API below. Never reach into its
## internals from scenes or other scripts.
##
## Integration points for the team:
##   - World hub (Person B): call start_level("level_1") when an NPC dialog
##     ends to launch that level. Use is_level_unlocked() to decide between
##     the start dialog and a "coming soon" line.
##   - Level scene (Person C): the level itself emits on_shift_completed(score)
##     for the HUD; after the evaluation screen, the "Next" button calls
##     level_completed(level_id, score) — recorded here, then back to the hub.
##   - Evaluation screen (Person D): get_score(level_id) and
##     get_level_status(level_id) drive the stars and the bot's review lines.

## Path to the hub scene the player returns to after every level.
const WORLD_HUB_PATH := "res://scenes/world_hub/world_hub.tscn"

## Default transition effect used for all scene changes.
const TRANSITION_PATH := "res://scenes/scene_transitions/fade_transition.tscn"

## Registry of playable levels. Add an entry here when a level scene lands.
## The key is the stable id used by the whole codebase; the value is the
## scene path. Scenes are loaded by path so missing levels don't break the
## editor project file.
const LEVELS := {
	# TEMP (Person C, mvp-level1 branch): pointed at the real Zero-G Vet
	# Clinic scene for testing. To revert to A's placeholder stub, change
	# back to "res://scenes/levels/level_1.tscn".
	"level_1": "res://scenes/levels/level_1_vet_clinic.tscn",
	# "level_2": "res://scenes/levels/level_2.tscn",  # add when Person C builds it
	# "level_3": "res://scenes/levels/level_3.tscn",  # add when Person D builds it
	# "level_4": "res://scenes/levels/level_4.tscn",  # add when Person D builds it
}

## Completion order. A level is unlocked once the previous entry is cleared.
## The first level is always unlocked.
const LEVEL_ORDER: Array[String] = ["level_1", "level_2", "level_3", "level_4"]

## Cleared levels: level_id -> best score (int).
var completed_levels := {}

## The level the player is currently inside; used to validate completion calls.
var current_level_id := ""


## Starts a level: validates the id, marks it active, fades into its scene.
func start_level(level_id: String) -> void:
	if not is_level_unlocked(level_id):
		push_warning("GameManager: level '%s' is locked." % level_id)
		return

	if not LEVELS.has(level_id) or not FileAccess.file_exists(LEVELS[level_id]):
		push_warning("GameManager: no scene registered for level '%s'." % level_id)
		return

	current_level_id = level_id
	SceneTransitionManager.change_scene_with_transition(
		load(LEVELS[level_id]),
		load(TRANSITION_PATH)
	)


## Records the score for the given level and returns the player to the hub.
## Call this from the evaluation screen's "Next" button (Person D), or from
## the level itself when the shift ends (Person C). Only the best score is kept.
func level_completed(level_id: String, score: int) -> void:
	if level_id != current_level_id:
		push_warning(
			"GameManager: completion reported for '%s' but '%s' is active."
			% [level_id, current_level_id]
		)
		return

	completed_levels[level_id] = max(completed_levels.get(level_id, 0), score)
	return_to_hub()


## Fades back to the world hub. Safe to call from pause/abandon paths too.
func return_to_hub() -> void:
	current_level_id = ""
	SceneTransitionManager.change_scene_with_transition(
		load(WORLD_HUB_PATH),
		load(TRANSITION_PATH)
	)


## True when the level has been cleared at least once.
func get_level_status(level_id: String) -> bool:
	return completed_levels.has(level_id)


## True when the player may start the level (sequential unlock).
## The first level — and any unknown id — is always treated as unlocked.
func is_level_unlocked(level_id: String) -> bool:
	var index := LEVEL_ORDER.find(level_id)
	if index <= 0:
		return true
	return completed_levels.has(LEVEL_ORDER[index - 1])


## Best score achieved on a level (0 if never cleared).
func get_score(level_id: String) -> int:
	return completed_levels.get(level_id, 0)


## Number of cleared levels. Useful for the ending screen later (Person D).
func get_completed_count() -> int:
	return completed_levels.size()


## Clears all progress. Dev/testing helper — callable from the console.
func reset_progress() -> void:
	completed_levels.clear()
	current_level_id = ""
