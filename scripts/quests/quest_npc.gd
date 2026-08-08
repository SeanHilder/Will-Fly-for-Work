class_name QuestNPC extends Interactable

## An NPC that talks, launches a minigame, and hands over a ship part on
## success. Drop it on a planet, fill in the exported fields, done.
##
## Talk flow:
##   UNSTARTED -> offer_lines, then the minigame launches on the last line
##   won        -> success_lines, part granted, quest marked COMPLETE
##   lost       -> fail_lines, quest returns to UNSTARTED so it can be retried
##   COMPLETE   -> done_lines forever after

@export_group("Identity")
## Unique across the whole game, e.g. &"grubnak_heat_shield".
@export var quest_id: StringName = &""
## Ship part awarded on success, e.g. &"heat_shield". Leave empty for no reward.
@export var reward_part_id: StringName = &""

@export_group("Wiring")
@export var dialog_box: DialogBox
@export var minigame_scene: PackedScene

@export_group("Dialogue")
@export var offer_lines: Array[String] = []
@export var success_lines: Array[String] = []
@export var fail_lines: Array[String] = []
@export var done_lines: Array[String] = []

var _lines: Array[String] = []
var _line_index := -1
var _launch_when_done := false
var _waiting_for_minigame := false


func _ready() -> void:
	super._ready()
	if quest_id == &"":
		push_warning("QuestNPC '%s' has no quest_id set" % name)
	MinigameHost.minigame_finished.connect(_on_minigame_finished)



func _on_area_exited(area: Area2D) -> void:
	super._on_area_exited(area)
	if not _waiting_for_minigame:
		_close_dialog()


func _on_interact(interactor: Interactor) -> void:
	super._on_interact(interactor)
	if _waiting_for_minigame or MinigameHost.is_running():
		return
	_advance()


# --- dialogue ---------------------------------------------------------------

func _advance() -> void:
	if _line_index == -1:
		_begin_current_conversation()

	if _line_index >= _lines.size() - 1:
		var should_launch := _launch_when_done
		_close_dialog()
		if should_launch:
			_launch_minigame()
		return

	_line_index += 1
	dialog_box.set_text(_lines[_line_index])


func _begin_current_conversation() -> void:
	_launch_when_done = false

	if GameState.is_quest_complete(quest_id):
		_lines = done_lines
	else:
		_lines = offer_lines
		_launch_when_done = minigame_scene != null

	if _lines.is_empty():
		_lines = ["..."]
		_launch_when_done = false

	dialog_box.is_on = true


func _say(lines: Array[String]) -> void:
	if lines.is_empty():
		return
	_lines = lines
	_line_index = 0
	_launch_when_done = false
	dialog_box.is_on = true
	dialog_box.set_text(_lines[0])


func _close_dialog() -> void:
	_line_index = -1
	_launch_when_done = false
	if dialog_box:
		dialog_box.is_on = false


# --- minigame ---------------------------------------------------------------

func _launch_minigame() -> void:
	GameState.set_quest_state(quest_id, GameState.QuestState.ACTIVE)
	_waiting_for_minigame = MinigameHost.launch(quest_id, minigame_scene)
	if not _waiting_for_minigame:
		GameState.set_quest_state(quest_id, GameState.QuestState.UNSTARTED)


func _on_minigame_finished(minigame_id: StringName, won: bool) -> void:
	# The host is global, so ignore results belonging to other NPCs.
	if minigame_id != quest_id:
		return
	_waiting_for_minigame = false

	if won:
		GameState.set_quest_state(quest_id, GameState.QuestState.COMPLETE)
		if reward_part_id != &"":
			GameState.grant_part(reward_part_id)
		GameState.save_progress()
		_say(success_lines)
	else:
		GameState.set_quest_state(quest_id, GameState.QuestState.UNSTARTED)
		_say(fail_lines)
