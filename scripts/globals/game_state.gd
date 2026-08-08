extends Node

## Persistent player progress: ship parts owned and quest states.
## Survives scene changes because it is registered as an autoload.

signal part_acquired(part_id: StringName)
signal quest_state_changed(quest_id: StringName, state: int)

enum QuestState { UNSTARTED, ACTIVE, COMPLETE }

const SAVE_PATH := "user://progress.dat"

## part_id (StringName) -> true
var parts: Dictionary = {}
## quest_id (StringName) -> QuestState
var quests: Dictionary = {}


# --- ship parts -------------------------------------------------------------

func has_part(part_id: StringName) -> bool:
	return parts.get(part_id, false)


func grant_part(part_id: StringName) -> void:
	if has_part(part_id):
		return
	parts[part_id] = true
	part_acquired.emit(part_id)


func part_count() -> int:
	return parts.size()


## True when every part in the list is owned - use this to gate departure.
func has_all_parts(required: Array) -> bool:
	for id in required:
		if not has_part(id):
			return false
	return true


# --- quests -----------------------------------------------------------------

func get_quest_state(quest_id: StringName) -> QuestState:
	return quests.get(quest_id, QuestState.UNSTARTED)


func set_quest_state(quest_id: StringName, state: QuestState) -> void:
	if get_quest_state(quest_id) == state:
		return
	quests[quest_id] = state
	quest_state_changed.emit(quest_id, state)


func is_quest_complete(quest_id: StringName) -> bool:
	return get_quest_state(quest_id) == QuestState.COMPLETE


# --- persistence ------------------------------------------------------------

func save_progress() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("GameState: could not open %s for writing" % SAVE_PATH)
		return
	file.store_var({
		"parts": parts,
		"quests": quests,
	})


func load_progress() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return
	var data = file.get_var()
	if typeof(data) != TYPE_DICTIONARY:
		return
	parts = data.get("parts", {})
	quests = data.get("quests", {})


## Wipe progress - handy while testing.
func reset() -> void:
	parts.clear()
	quests.clear()
