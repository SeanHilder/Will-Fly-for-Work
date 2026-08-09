class_name MinigameEntryInteractable extends StoryDialogInteractable
## StoryDialogInteractable that launches an overlay minigame (MinigameHost)
## when its dialog finishes. Counterpart to LevelEntryInteractable for jobs
## that are minigames rather than full level scenes.

@export var minigame_id: StringName = &"job"
@export var minigame_scene: PackedScene


func _advance_dialog():
	if MinigameHost.is_running():
		return
	var is_last: bool = _current_line_index >= dialog_lines.size() - 1
	super._advance_dialog()
	if is_last and minigame_scene != null:
		MinigameHost.launch(minigame_id, minigame_scene)
