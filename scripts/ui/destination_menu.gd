class_name DestinationMenu extends CanvasLayer
## Clickable destination picker for rockets. A RocketMenuInteractable calls
## open() with its options; locked destinations render disabled with the
## reason in the label. STAY or Esc closes.

var _dim: ColorRect
var _buttons_box: VBoxContainer
var _is_open := false


func _ready() -> void:
	layer = 40
	visible = false

	_dim = ColorRect.new()
	_dim.color = Color(0.02, 0.02, 0.06, 0.7)
	_dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_dim)
	_dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_dim.add_child(center)

	var panel := PanelContainer.new()
	center.add_child(panel)

	var margin := MarginContainer.new()
	for side in ["margin_left", "margin_right", "margin_top", "margin_bottom"]:
		margin.add_theme_constant_override(side, 24)
	panel.add_child(margin)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 12)
	margin.add_child(column)

	var title := Label.new()
	title.text = "JOBB-E AIRWAYS — SELECT DESTINATION"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color(0.49, 0.91, 1.0))
	column.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "\"Statistically, every option is a mistake.\""
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 14)
	subtitle.add_theme_color_override("font_color", Color(0.55, 0.6, 0.7))
	column.add_child(subtitle)

	_buttons_box = VBoxContainer.new()
	_buttons_box.add_theme_constant_override("separation", 8)
	column.add_child(_buttons_box)

	var stay := Button.new()
	stay.text = "STAY (coward)"
	stay.custom_minimum_size = Vector2(380, 44)
	stay.pressed.connect(close)
	column.add_child(stay)


func is_open() -> bool:
	return _is_open


## options: Array of { label: String, path: String, locked_reason: String }.
## Empty locked_reason means travel is allowed.
func open(options: Array) -> void:
	if _is_open:
		return
	_is_open = true
	visible = true

	for child in _buttons_box.get_children():
		child.queue_free()

	for opt in options:
		var b := Button.new()
		b.custom_minimum_size = Vector2(380, 52)
		b.add_theme_font_size_override("font_size", 20)
		if opt.locked_reason != "":
			b.disabled = true
			b.text = "%s  [%s]" % [opt.label, opt.locked_reason]
		else:
			b.text = opt.label
			b.pressed.connect(_travel.bind(opt.path))
		_buttons_box.add_child(b)


func close() -> void:
	_is_open = false
	visible = false


func _travel(path: String) -> void:
	close()
	SceneTransitionManager.change_scene_with_transition(
		load(path),
		load(GameManager.TRANSITION_PATH)
	)


func _unhandled_input(event: InputEvent) -> void:
	if _is_open and event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()
