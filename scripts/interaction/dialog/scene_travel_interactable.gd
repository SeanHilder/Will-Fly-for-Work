class_name SceneTravelInteractable extends StoryDialogInteractable
## StoryDialogInteractable that travels to another scene when the dialog
## finishes — used by the rockets to fly between the hub and other planets.

@export_file("*.tscn") var target_scene_path := ""


func _advance_dialog():
	var is_last: bool = _current_line_index >= dialog_lines.size() - 1
	super._advance_dialog()
	if is_last and target_scene_path != "":
		SceneTransitionManager.change_scene_with_transition(
			load(target_scene_path),
			load(GameManager.TRANSITION_PATH)
		)
