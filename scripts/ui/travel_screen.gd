class_name TravelScreen extends Control
## Between-planet travel sequence: the planet you left slides off to the left
## and shrinks away, while the destination swells up and takes over the
## screen. When the animation ends, the real destination scene loads.
##
## Callers set the trip with set_trip() and then transition to
## TravelScreen.SCENE_PATH — see DestinationMenu and SceneTravelInteractable.

const SCENE_PATH := "res://scenes/ui/travel_screen.tscn"

const PLANET_SHADER := preload("res://shaders/planet_earth.gdshader")
const RINGED_SHADER := preload("res://shaders/planet_ringed.gdshader")

## Planet id -> display name, look, and the shader uniforms that recolor it.
## Anything not listed falls back to EARTH's palette.
const PLANETS := {
	"earth": {
		"name": "EARTH",
		"ringed": false,
		"params": {
			"ocean_deep": Color(0.02, 0.09, 0.28),
			"ocean_shallow": Color(0.06, 0.32, 0.56),
			"land_low": Color(0.13, 0.34, 0.16),
			"land_high": Color(0.45, 0.39, 0.22),
			"atmo_color": Color(0.35, 0.65, 1.0),
			"sea_level": 0.54,
			"cloud_amount": 0.45,
		},
	},
	"glorbon": {
		"name": "GLORBON-5",
		"ringed": false,
		"params": {
			"ocean_deep": Color(0.18, 0.05, 0.26),
			"ocean_shallow": Color(0.42, 0.14, 0.5),
			"land_low": Color(0.15, 0.42, 0.38),
			"land_high": Color(0.62, 0.75, 0.3),
			"atmo_color": Color(0.75, 0.4, 1.0),
			"sea_level": 0.52,
			"cloud_amount": 0.35,
		},
	},
	"cinderon": {
		"name": "CINDERON-3",
		"ringed": false,
		"params": {
			"ocean_deep": Color(0.25, 0.05, 0.02),
			"ocean_shallow": Color(0.62, 0.18, 0.05),
			"land_low": Color(0.45, 0.14, 0.06),
			"land_high": Color(0.95, 0.55, 0.15),
			"ice_color": Color(0.98, 0.8, 0.4),
			"cloud_color": Color(0.5, 0.3, 0.25),
			"atmo_color": Color(1.0, 0.45, 0.15),
			"sea_level": 0.46,
			"cloud_amount": 0.25,
			"ice_extent": 0.95,
		},
	},
	"ataraxia": {
		"name": "ATARAXIA",
		"ringed": true,  # that asteroid belt VOLT warned you about
		"params": {
			"ocean_deep": Color(0.09, 0.28, 0.26),
			"ocean_shallow": Color(0.28, 0.6, 0.55),
			"land_low": Color(0.42, 0.62, 0.45),
			"land_high": Color(0.75, 0.85, 0.7),
			"cloud_color": Color(0.92, 1.0, 0.98),
			"atmo_color": Color(0.5, 0.95, 0.85),
			"ring_color": Color(0.7, 0.8, 0.78),
			"sea_level": 0.5,
			"cloud_amount": 0.4,
		},
	},
}

# --- trip parameters, set by the caller before the scene loads ---------------
static var from_planet := "earth"
static var to_planet := "glorbon"
static var target_path := ""


## Records where we're flying. Call this, then change_scene to SCENE_PATH.
static func set_trip(from_id: String, to_id: String, destination_path: String) -> void:
	from_planet = from_id
	to_planet = to_id
	target_path = destination_path


@export var duration := 6.0

var _skipped := false


func _ready() -> void:
	var screen := get_viewport_rect().size

	var from_node := _make_planet(from_planet)
	add_child(from_node)
	var to_node := _make_planet(to_planet)
	add_child(to_node)

	# Departing planet: mid-sized, centre-right of frame, then sails off left.
	_set_rect(from_node, screen * Vector2(0.52, 0.5), 260.0)
	# Destination: a far-off speck on the right that ends up swallowing the screen.
	_set_rect(to_node, screen * Vector2(0.88, 0.4), 10.0)

	var caption := Label.new()
	caption.text = "NOW APPROACHING"
	caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caption.add_theme_font_size_override("font_size", 18)
	caption.add_theme_color_override("font_color", Color(0.62, 0.7, 0.82))
	caption.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	caption.offset_top = -120.0
	caption.modulate.a = 0.0
	add_child(caption)

	var name_label := Label.new()
	name_label.text = _planet_data(to_planet).name
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 46)
	name_label.add_theme_color_override("font_color", Color.WHITE)
	name_label.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	name_label.offset_top = -96.0
	name_label.modulate.a = 0.0
	add_child(name_label)

	var hint := Label.new()
	hint.text = "click to skip"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	hint.add_theme_font_size_override("font_size", 12)
	hint.add_theme_color_override("font_color", Color(0.4, 0.44, 0.52))
	hint.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	hint.offset_top = -26.0
	hint.offset_right = -16.0
	add_child(hint)

	var tween := create_tween().set_parallel(true)
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	# Depart: shrink and slide out past the left edge.
	tween.tween_method(
		_rect_setter(from_node), Vector4(screen.x * 0.52, screen.y * 0.5, 260.0, 1.0),
		Vector4(-200.0, screen.y * 0.62, 40.0, 0.0), duration * 0.8
	)
	# Arrive: swell from a speck to larger than the screen. Eased so most of
	# the growth happens late — a long approach, then it looms.
	tween.tween_method(
		_rect_setter(to_node), Vector4(screen.x * 0.88, screen.y * 0.4, 10.0, 1.0),
		Vector4(screen.x * 0.5, screen.y * 0.5, maxf(screen.x, screen.y) * 2.3, 1.0), duration
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

	tween.chain().tween_property(caption, "modulate:a", 1.0, 0.5)
	tween.parallel().tween_property(name_label, "modulate:a", 1.0, 0.5)

	get_tree().create_timer(duration + 0.8).timeout.connect(_arrive)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		_arrive()


func _arrive() -> void:
	if _skipped:
		return
	_skipped = true
	if target_path == "":
		push_warning("TravelScreen: no target_path set, returning to hub")
		GameManager.return_to_hub()
		return
	SceneTransitionManager.change_scene_with_transition(
		load(target_path),
		load(GameManager.TRANSITION_PATH)
	)


# --- planet building --------------------------------------------------------

func _planet_data(id: String) -> Dictionary:
	return PLANETS.get(id, PLANETS["earth"])


func _make_planet(id: String) -> ColorRect:
	var data := _planet_data(id)
	var mat := ShaderMaterial.new()
	mat.shader = RINGED_SHADER if data.ringed else PLANET_SHADER
	for key in data.params:
		mat.set_shader_parameter(key, data.params[key])
	# A little spin so the globes feel alive during the flight.
	mat.set_shader_parameter("spin_speed", 0.06)
	mat.set_shader_parameter("cloud_spin_speed", 0.08)

	var rect := ColorRect.new()
	rect.color = Color(1, 1, 1, 1)
	rect.material = mat
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return rect


## Places a square rect by its centre point and side length.
func _set_rect(node: Control, centre: Vector2, side: float) -> void:
	node.size = Vector2(side, side)
	node.position = centre - Vector2(side, side) * 0.5


## Returns a setter for tween_method: Vector4(centre_x, centre_y, side, alpha).
func _rect_setter(node: Control) -> Callable:
	return func(v: Vector4) -> void:
		_set_rect(node, Vector2(v.x, v.y), v.z)
		node.modulate.a = v.w
