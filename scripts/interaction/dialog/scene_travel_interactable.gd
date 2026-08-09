class_name SceneTravelInteractable extends StoryDialogInteractable
## StoryDialogInteractable that travels to another scene when the dialog
## finishes — used by the rockets to fly between the hub and other planets.

@export_file("*.tscn") var target_scene_path := ""
## Optional TravelScreen planet ids. Set BOTH to play the fly-by animation
## before arriving; leave blank for a plain scene change (job scenes, etc).
@export var from_planet := ""
@export var to_planet := ""

var _traveling := false


func _advance_dialog():
	if _traveling:
		return
	var is_last: bool = _current_line_index >= dialog_lines.size() - 1
	super._advance_dialog()
	if is_last and target_scene_path != "":
		_traveling = true
		var path := target_scene_path
		if from_planet != "" and to_planet != "":
			TravelScreen.set_trip(from_planet, to_planet, path)
			path = TravelScreen.SCENE_PATH
		SceneTransitionManager.change_scene_with_transition(
			load(path),
			load(GameManager.TRANSITION_PATH)
		)
