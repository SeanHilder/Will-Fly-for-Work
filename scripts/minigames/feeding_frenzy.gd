extends Control

## Feeding Frenzy — GLORP's job on Glorbon-5, a standalone scene.
## Snacks and robot garbage rain down; drag the hungry hatchling under the
## food. Catch the quota, don't feed it garbage, don't let snacks splat.
##
## Win  -> fade back to the alien world (paid in fuel, fictionally).
## Lose -> fade into a fresh attempt of this same scene.

const RETURN_SCENE := "res://scenes/world_hub/alien_world.tscn"
const SELF_SCENE := "res://scenes/minigames/feeding_frenzy.tscn"

@export var snack_quota: int = 10
@export var max_mistakes: int = 5
@export var start_interval: float = 1.1
@export var min_interval: float = 0.45
@export var start_speed: float = 260.0
@export var max_speed: float = 520.0
@export var junk_chance: float = 0.3

const ITEM_KINDS := [
	{"tex": preload("res://sprites/minigames/grub.png"), "good": true},
	{"tex": preload("res://sprites/minigames/egg.png"), "good": true},
	{"tex": preload("res://sprites/minigames/jelly.png"), "good": true},
	{"tex": preload("res://sprites/minigames/rock.png"), "good": false},
	{"tex": preload("res://sprites/minigames/battery.png"), "good": false},
]

const HATCHLING_TEX := preload("res://sprites/minigames/hatchling.png")

var _hatchling: Sprite2D
var _status: Label
var _flavor: Label
var _items: Array = []  # { node: Sprite2D, vy: float, good: bool }
var _caught := 0
var _mistakes := 0
var _spawn_timer := 0.4
var _playing := true


func _ready() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.15, 0.11, 0.21)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var ground := ColorRect.new()
	ground.color = Color(0.24, 0.19, 0.32)
	ground.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	ground.offset_top = -88.0
	add_child(ground)

	var heading := Label.new()
	heading.text = "FEEDING FRENZY"
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.add_theme_font_size_override("font_size", 40)
	heading.add_theme_color_override("font_color", Color("d6e9ff"))
	heading.set_anchors_preset(Control.PRESET_TOP_WIDE)
	heading.offset_top = 20.0
	add_child(heading)

	_status = Label.new()
	_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status.add_theme_font_size_override("font_size", 22)
	_status.add_theme_color_override("font_color", Color("9fb8d8"))
	_status.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_status.offset_top = 74.0
	add_child(_status)

	_flavor = Label.new()
	_flavor.text = "Drag the hatchling under the snacks. NO robot garbage."
	_flavor.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_flavor.add_theme_font_size_override("font_size", 16)
	_flavor.add_theme_color_override("font_color", Color(0.6, 0.55, 0.7))
	_flavor.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_flavor.offset_top = -32.0
	add_child(_flavor)

	_hatchling = Sprite2D.new()
	_hatchling.texture = HATCHLING_TEX
	_hatchling.scale = Vector2(4, 4)
	add_child(_hatchling)

	_update_status()


func _process(delta: float) -> void:
	if not _playing:
		return

	var difficulty: float = float(_caught) / float(maxi(snack_quota, 1))

	# Hatchling follows the mouse horizontally, waddling along the ground.
	var hx := clampf(get_local_mouse_position().x, 60.0, size.x - 60.0)
	_hatchling.position = Vector2(hx, size.y - 130.0)

	_spawn_timer -= delta
	if _spawn_timer <= 0.0:
		_spawn_item(difficulty)
		_spawn_timer = lerpf(start_interval, min_interval, difficulty)

	# The open mouth, in scene coordinates.
	var mouth := Rect2(_hatchling.position + Vector2(-38.0, -40.0), Vector2(76.0, 34.0))

	for item in _items.duplicate():
		var node: Sprite2D = item.node
		node.position.y += item.vy * delta
		node.rotation += delta * (0.8 if item.good else 2.2)

		if mouth.has_point(node.position):
			_on_caught(item)
		elif node.position.y > size.y - 88.0:
			_on_splat(item)


func _spawn_item(difficulty: float) -> void:
	var want_junk := randf() < lerpf(junk_chance, junk_chance + 0.25, difficulty)
	var pool := ITEM_KINDS.filter(func(k): return k.good != want_junk)
	var kind: Dictionary = pool.pick_random()

	var node := Sprite2D.new()
	node.texture = kind.tex
	node.scale = Vector2(4, 4)
	node.position = Vector2(randf_range(60.0, size.x - 60.0), -40.0)
	add_child(node)

	_items.append({
		"node": node,
		"vy": lerpf(start_speed, max_speed, difficulty) * randf_range(0.8, 1.2),
		"good": kind.good,
	})


func _on_caught(item: Dictionary) -> void:
	_remove_item(item)
	_gulp()
	if item.good:
		_caught += 1
		_flash_hatchling(Color(0.7, 1.0, 0.75))
		if _caught >= snack_quota:
			_win()
			return
	else:
		_mistakes += 1
		_flash_hatchling(Color(1.0, 0.5, 0.5))
		if _mistakes >= max_mistakes:
			_lose()
			return
	_update_status()


func _on_splat(item: Dictionary) -> void:
	var was_good: bool = item.good
	_remove_item(item)
	if was_good:
		_mistakes += 1
		_flash_hatchling(Color(1.0, 0.85, 0.5))
		if _mistakes >= max_mistakes:
			_lose()
			return
	_update_status()


func _remove_item(item: Dictionary) -> void:
	_items.erase(item)
	item.node.queue_free()


func _gulp() -> void:
	# Quick chomp squash.
	var tween := create_tween()
	tween.tween_property(_hatchling, "scale", Vector2(4.6, 3.2), 0.06)
	tween.tween_property(_hatchling, "scale", Vector2(4, 4), 0.18)


func _flash_hatchling(color: Color) -> void:
	var tween := create_tween()
	tween.tween_property(_hatchling, "modulate", color, 0.06)
	tween.tween_property(_hatchling, "modulate", Color.WHITE, 0.3)


func _update_status() -> void:
	_status.text = "Fed: %d/%d    Complaints: %d/%d" % [
		_caught, snack_quota, _mistakes, max_mistakes
	]


func _win() -> void:
	_playing = false
	GameState.grant_part(&"heat_shield")
	GameState.save_progress()
	_status.text = "SHIFT COMPLETE. PAYMENT: ONE (1) GENTLY USED HEAT SHIELD."
	_flavor.text = "GLORP is proud. The hatchling naps. Ataraxia awaits."
	get_tree().create_timer(1.8).timeout.connect(func() -> void:
		SceneTransitionManager.change_scene_with_transition(
			load(RETURN_SCENE),
			load(GameManager.TRANSITION_PATH)
		)
	)


func _lose() -> void:
	_playing = false
	_status.text = "THE HATCHLING RIOTS. NO FUEL."
	_flavor.text = "GLORP suggests you try again. Immediately."
	get_tree().create_timer(1.6).timeout.connect(func() -> void:
		SceneTransitionManager.change_scene_with_transition(
			load(SELF_SCENE),
			load(GameManager.TRANSITION_PATH)
		)
	)
