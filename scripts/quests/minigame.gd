class_name Minigame extends Control

## Base class every minigame extends. The only contract is: emit `finished`
## exactly once, with true if the player succeeded.
##
## MinigameHost instantiates this on a CanvasLayer above the running level and
## pauses the tree, so the planet underneath stays loaded and needs no restore.

signal finished(won: bool)

## Shown in the minigame's own header.
@export var title: String = "Minigame"

## Track played while this minigame is up. The previous track resumes on exit.
@export var music_path: String = "res://audio/music/minigame_theme.mp3"

var _is_over := false


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	# Runs while the rest of the tree is paused.
	process_mode = Node.PROCESS_MODE_ALWAYS
	# A Control parented to a CanvasLayer has no Control parent to size it, so
	# anchors alone leave it at zero size. Set the size explicitly, then track
	# the viewport from then on.
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_match_viewport()
	get_viewport().size_changed.connect(_match_viewport)
	if music_path != "" and ResourceLoader.exists(music_path):
		AudioManager.push_music(music_path)
	_build()
	start()


func _match_viewport() -> void:
	size = get_viewport_rect().size
	position = Vector2.ZERO


## Override: construct the minigame's UI.
func _build() -> void:
	pass


## Override: begin play. Called once after _build().
func start() -> void:
	pass


func win() -> void:
	if _is_over:
		return
	_is_over = true
	finished.emit(true)


func lose() -> void:
	if _is_over:
		return
	_is_over = true
	finished.emit(false)
