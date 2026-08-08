extends CanvasLayer

## Runs a minigame as an overlay on top of the currently loaded level.
##
## The level is never unloaded - the tree is simply paused - so there is no
## player position, NPC state or collected-item state to save and restore.

signal minigame_finished(minigame_id: StringName, won: bool)

var _current: Minigame = null
var _current_id: StringName = &""


func _ready() -> void:
	layer = 50
	# Keeps this node and its children ticking while get_tree().paused is true.
	process_mode = Node.PROCESS_MODE_ALWAYS


func is_running() -> bool:
	return _current != null


## Returns false if a minigame is already up, or the scene is unusable.
func launch(minigame_id: StringName, scene: PackedScene) -> bool:
	if _current != null:
		push_warning("MinigameHost: '%s' ignored, one is already running" % minigame_id)
		return false
	if scene == null:
		push_error("MinigameHost: no scene given for '%s'" % minigame_id)
		return false

	var instance := scene.instantiate()
	if not instance is Minigame:
		push_error("MinigameHost: '%s' root must extend Minigame" % minigame_id)
		instance.queue_free()
		return false

	_current = instance
	_current_id = minigame_id
	_current.finished.connect(_on_minigame_finished)
	add_child(_current)
	get_tree().paused = true
	return true


func _on_minigame_finished(won: bool) -> void:
	var finished_id := _current_id

	get_tree().paused = false
	if is_instance_valid(_current):
		_current.queue_free()
	_current = null
	_current_id = &""

	minigame_finished.emit(finished_id, won)
