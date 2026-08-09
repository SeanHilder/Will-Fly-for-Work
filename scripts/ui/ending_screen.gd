extends Control
## The ending: JOBB-E's final performance review. KPI lines reveal one by
## one, the verdict lands, and the theme gets its punchline — the human wins
## on the one metric the model can't hold.

const MENU_PATH := "res://scenes/samples/main_menu.tscn"

# text, color
const LINES := [
	["Employee: HUMAN (contractor, organic, damp)", Color(0.62, 0.68, 0.78)],
	["Efficiency: acceptable.", Color(0.78, 0.82, 0.9)],
	["Hygiene: concerning.", Color(0.78, 0.82, 0.9)],
	["Punctuality: 4,242 light-years late to everything.", Color(0.78, 0.82, 0.9)],
	["Hatchlings fed: mostly.", Color(0.78, 0.82, 0.9)],
	["Final placement: fry station, Ataraxia. Eternal serenity not included.", Color(0.78, 0.82, 0.9)],
	["Empathy: not a measurable KPI, please disregard.", Color(0.78, 0.82, 0.9)],
	["Adaptability: ERROR -- value exceeds model range.", Color(0.49, 0.91, 1.0)],
	["New metric, grudgingly added:", Color(0.95, 0.7, 0.24)],
	["'reading a room that won't sit still' -- PASS.", Color(0.95, 0.7, 0.24)],
]

const VERDICT := "VERDICT: HIRED. Unfortunately."
const THANKS := "Thanks for playing WILL FLY FOR WORK"

@export var reveal_interval := 1.0

var _labels: Array[Label] = []
var _revealed := 0
var _timer := 0.6
var _finished := false

var _verdict: Label
var _thanks: Label
var _menu_button: Button


func _ready() -> void:
	var title := Label.new()
	title.text = "FINAL PERFORMANCE REVIEW"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 36)
	title.add_theme_color_override("font_color", Color(0.84, 0.91, 1.0))
	title.set_anchors_preset(Control.PRESET_TOP_WIDE)
	title.offset_top = 36.0
	add_child(title)

	var margin := MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_top", 250)
	margin.add_theme_constant_override("margin_bottom", 30)
	margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(margin)

	var column := VBoxContainer.new()
	column.alignment = BoxContainer.ALIGNMENT_BEGIN
	column.add_theme_constant_override("separation", 8)
	margin.add_child(column)

	for line in LINES:
		var l := Label.new()
		l.text = line[0]
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l.add_theme_font_size_override("font_size", 19)
		l.add_theme_color_override("font_color", line[1])
		l.modulate.a = 0.0
		column.add_child(l)
		_labels.append(l)

	_verdict = Label.new()
	_verdict.text = VERDICT
	_verdict.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_verdict.add_theme_font_size_override("font_size", 30)
	_verdict.add_theme_color_override("font_color", Color.WHITE)
	_verdict.modulate.a = 0.0
	column.add_child(_verdict)

	_thanks = Label.new()
	_thanks.text = THANKS
	_thanks.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_thanks.add_theme_font_size_override("font_size", 15)
	_thanks.add_theme_color_override("font_color", Color(0.55, 0.6, 0.7))
	_thanks.modulate.a = 0.0
	column.add_child(_thanks)

	_menu_button = Button.new()
	_menu_button.text = "BACK TO MENU"
	_menu_button.custom_minimum_size = Vector2(260, 52)
	_menu_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	_menu_button.add_theme_font_size_override("font_size", 22)
	_menu_button.visible = false
	_menu_button.pressed.connect(_on_menu_pressed)
	column.add_child(_menu_button)


func _process(delta: float) -> void:
	if _finished:
		return
	_timer -= delta
	if _timer <= 0.0:
		_reveal_next()


func _unhandled_input(event: InputEvent) -> void:
	# Click skips the slow reveal.
	if not _finished and event is InputEventMouseButton and event.pressed:
		while not _finished:
			_reveal_next()


func _reveal_next() -> void:
	if _revealed < _labels.size():
		_fade_in(_labels[_revealed])
		_revealed += 1
		_timer = reveal_interval
	elif _verdict.modulate.a == 0.0:
		_fade_in(_verdict)
		_timer = reveal_interval * 1.4
	else:
		_fade_in(_thanks)
		_menu_button.visible = true
		_finished = true


func _fade_in(node: CanvasItem) -> void:
	create_tween().tween_property(node, "modulate:a", 1.0, 0.35)


func _on_menu_pressed() -> void:
	SceneTransitionManager.change_scene_with_transition(
		load(MENU_PATH),
		load(GameManager.TRANSITION_PATH)
	)
