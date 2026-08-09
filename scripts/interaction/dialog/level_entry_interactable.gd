class_name LevelEntryInteractable extends StoryDialogInteractable
## StoryDialogInteractable that launches a level when its dialog finishes.
##
## Picks start_lines or locked_lines when the dialog opens, based on
## GameManager.is_level_unlocked(). If the level is unlocked, the last
## advance hands off to GameManager.start_level() instead of just closing.

@export var level_id := "level_1"
## Dialog shown when the level is unlocked; ends with the launch.
@export var start_lines: Array[String] = []
## Dialog shown when the level is still locked; just closes.
@export var locked_lines: Array[String] = ["JOBB-E|No shifts available yet."]


func _advance_dialog():
	var unlocked: bool = GameManager.is_level_unlocked(level_id)
	if _current_line_index == -1:
		dialog_lines = start_lines if unlocked else locked_lines
	var is_last: bool = _current_line_index >= dialog_lines.size() - 1
	super._advance_dialog()
	if is_last and unlocked:
		GameManager.start_level(level_id)
