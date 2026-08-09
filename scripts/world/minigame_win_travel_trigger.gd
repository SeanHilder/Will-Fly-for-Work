class_name MinigameWinTravelTrigger extends Node
## Travels to a scene the first time a given minigame is won.
## Drop into a world scene: watches MinigameHost, fires once, short delay so
## the win lands before the fade. Used on Ataraxia: Burger Rush -> ending.

@export var minigame_id: StringName = &""
@export_file("*.tscn") var target_scene_path := ""
@export var delay := 1.0

var _fired := false


func _ready() -> void:
	MinigameHost.minigame_finished.connect(_on_minigame_finished)


func _on_minigame_finished(id: StringName, won: bool) -> void:
	if _fired or id != minigame_id or not won or target_scene_path == "":
		return
	_fired = true
	await get_tree().create_timer(delay).timeout
	SceneTransitionManager.change_scene_with_transition(
		load(target_scene_path),
		load(GameManager.TRANSITION_PATH)
	)
