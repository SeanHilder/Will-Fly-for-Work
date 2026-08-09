extends Minigame

## Burger Rush — the one job on Ataraxia. Orders come in as ingredient
## sequences; click ingredients in order to build the burger. Wrong
## ingredient scraps the order. Lunch rush IS biological chaos.

@export var orders_quota: int = 5
@export var max_scraps: int = 3
@export var start_length: int = 3
@export var max_length: int = 6

# glyph, color, name
const INGREDIENTS := [
	["=", Color("ffc861"), "bun"],
	["#", Color("a8663c"), "patty"],
	["~", Color("ffe066"), "cheese"],
	["w", Color("5fd97a"), "lettuce"],
	["*", Color("ff6b6b"), "sauce"],
]

var _order: Array = []      # ingredient indices, first to last
var _progress := 0          # how much of the order is built
var _completed := 0
var _scraps := 0

var _ticket: Label
var _stack: Label
var _status: Label


func _build() -> void:
	var dim := ColorRect.new()
	dim.color = Color(0.06, 0.03, 0.02, 0.9)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(dim)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 20)
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	center.add_child(column)

	var heading := Label.new()
	heading.text = title
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.add_theme_font_size_override("font_size", 40)
	heading.add_theme_color_override("font_color", Color("ffd9a0"))
	column.add_child(heading)

	_status = Label.new()
	_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status.add_theme_font_size_override("font_size", 22)
	_status.add_theme_color_override("font_color", Color("d8b89f"))
	column.add_child(_status)

	_ticket = Label.new()
	_ticket.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_ticket.add_theme_font_size_override("font_size", 34)
	_ticket.add_theme_color_override("font_color", Color("ffffff"))
	column.add_child(_ticket)

	_stack = Label.new()
	_stack.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_stack.add_theme_font_size_override("font_size", 34)
	_stack.add_theme_color_override("font_color", Color("8ef0c0"))
	column.add_child(_stack)

	var buttons := HBoxContainer.new()
	buttons.add_theme_constant_override("separation", 14)
	buttons.alignment = BoxContainer.ALIGNMENT_CENTER
	column.add_child(buttons)

	for i in INGREDIENTS.size():
		var b := Button.new()
		b.text = "%s\n%s" % [INGREDIENTS[i][0], INGREDIENTS[i][2]]
		b.custom_minimum_size = Vector2(96, 84)
		b.add_theme_font_size_override("font_size", 22)
		b.add_theme_color_override("font_color", INGREDIENTS[i][1])
		b.pressed.connect(_on_ingredient.bind(i))
		buttons.add_child(b)

	var hint := Label.new()
	hint.text = "Build the ticket top to bottom. Wrong ingredient = scrapped order."
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", 16)
	hint.add_theme_color_override("font_color", Color(0.6, 0.5, 0.45))
	column.add_child(hint)


func start() -> void:
	_new_order()
	_update_labels()


func _on_ingredient(index: int) -> void:
	if _is_over:
		return

	if index == _order[_progress]:
		_progress += 1
		if _progress >= _order.size():
			_completed += 1
			_flash(_stack, Color("5fd97a"))
			if _completed >= orders_quota:
				_update_labels()
				win()
				return
			_new_order()
	else:
		_scraps += 1
		_flash(_ticket, Color("ff6b6b"))
		_progress = 0  # same ticket, start over
		if _scraps >= max_scraps:
			_update_labels()
			lose()
			return
	_update_labels()


func _new_order() -> void:
	var length: int = mini(start_length + _completed, max_length)
	_order = [0]  # bottom bun
	for i in length - 2:
		_order.append(randi_range(1, INGREDIENTS.size() - 1))
	_order.append(0)  # top bun
	_progress = 0


func _update_labels() -> void:
	var remaining := ""
	for i in range(_progress, _order.size()):
		remaining += INGREDIENTS[_order[i]][0] + " "
	_ticket.text = "TICKET:  " + remaining

	var built := ""
	for i in _progress:
		built += INGREDIENTS[_order[i]][0] + " "
	_stack.text = "STACK:   " + built if _progress > 0 else "STACK:   (empty)"

	_status.text = "Orders: %d/%d    Scrapped: %d/%d" % [
		_completed, orders_quota, _scraps, max_scraps
	]


func _flash(label: Label, color: Color) -> void:
	var tween := create_tween()
	tween.tween_property(label, "modulate", color, 0.08)
	tween.tween_property(label, "modulate", Color.WHITE, 0.3)
