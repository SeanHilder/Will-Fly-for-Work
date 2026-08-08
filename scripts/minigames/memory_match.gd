extends Minigame

## Alien glyph matching. Flip two cards; matching pairs stay up.
## Clear the board before running out of mistakes.

@export var columns: int = 4
@export var pair_count: int = 6
@export var max_mistakes: int = 8
@export var card_size: int = 104
@export var reveal_delay: float = 0.65

const GLYPHS := ["*", "#", "@", "+", "%", "=", "&", "$"]
const GLYPH_COLORS := [
	Color("ff6b6b"), Color("4bc8ff"), Color("9d7bff"), Color("5fd97a"),
	Color("ffc861"), Color("ff8ad4"), Color("6ff0d8"), Color("d0d6ff"),
]

var _grid: GridContainer
var _status: Label
var _cards: Array = []          # { button, glyph_index, matched }
var _flipped: Array = []        # indices awaiting comparison
var _matched_pairs := 0
var _mistakes := 0
var _busy := false


func _build() -> void:
	pair_count = clampi(pair_count, 2, GLYPHS.size())

	var dim := ColorRect.new()
	dim.color = Color(0.02, 0.02, 0.06, 0.88)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(dim)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 18)
	column.alignment = BoxContainer.ALIGNMENT_CENTER
	center.add_child(column)

	var heading := Label.new()
	heading.text = title
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.add_theme_font_size_override("font_size", 40)
	heading.add_theme_color_override("font_color", Color("d6e9ff"))
	column.add_child(heading)

	_status = Label.new()
	_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status.add_theme_font_size_override("font_size", 20)
	_status.add_theme_color_override("font_color", Color("8fa7d4"))
	column.add_child(_status)

	_grid = GridContainer.new()
	_grid.columns = columns
	_grid.add_theme_constant_override("h_separation", 12)
	_grid.add_theme_constant_override("v_separation", 12)
	column.add_child(_grid)


func start() -> void:
	var deck: Array[int] = []
	for i in pair_count:
		deck.append(i)
		deck.append(i)
	deck.shuffle()

	for index in deck.size():
		var button := Button.new()
		button.custom_minimum_size = Vector2(card_size, card_size)
		button.add_theme_font_size_override("font_size", 52)
		button.focus_mode = Control.FOCUS_NONE
		button.pressed.connect(_on_card_pressed.bind(index))
		_grid.add_child(button)

		_cards.append({
			"button": button,
			"glyph_index": deck[index],
			"matched": false,
		})
		_show_face_down(index)

	_update_status()


# --- interaction ------------------------------------------------------------

func _on_card_pressed(index: int) -> void:
	if _busy or _is_over:
		return
	var card: Dictionary = _cards[index]
	if card["matched"] or index in _flipped:
		return

	_flipped.append(index)
	_show_face_up(index)

	if _flipped.size() < 2:
		return

	_busy = true
	var a: int = _flipped[0]
	var b: int = _flipped[1]

	if _cards[a]["glyph_index"] == _cards[b]["glyph_index"]:
		_cards[a]["matched"] = true
		_cards[b]["matched"] = true
		_show_matched(a)
		_show_matched(b)
		_matched_pairs += 1
		_flipped.clear()
		_busy = false
		_update_status()
		if _matched_pairs >= pair_count:
			await _pause_aware_wait(0.45)
			win()
		return

	_mistakes += 1
	_update_status()
	# process_always = true, so this ticks while the level below is paused.
	await _pause_aware_wait(reveal_delay)
	_show_face_down(a)
	_show_face_down(b)
	_flipped.clear()
	_busy = false

	if _mistakes >= max_mistakes:
		lose()


func _pause_aware_wait(seconds: float) -> void:
	await get_tree().create_timer(seconds, true, false, true).timeout


# --- card appearance --------------------------------------------------------

func _show_face_down(index: int) -> void:
	var button: Button = _cards[index]["button"]
	button.text = "?"
	button.add_theme_color_override("font_color", Color("3f5a8a"))
	_apply_style(button, Color("0e1230"), Color("2e5c8a"))


func _show_face_up(index: int) -> void:
	var glyph_index: int = _cards[index]["glyph_index"]
	var button: Button = _cards[index]["button"]
	button.text = GLYPHS[glyph_index]
	button.add_theme_color_override("font_color", Color("07070c"))
	_apply_style(button, GLYPH_COLORS[glyph_index], Color("ffffff"))


func _show_matched(index: int) -> void:
	_show_face_up(index)
	var button: Button = _cards[index]["button"]
	button.modulate = Color(1, 1, 1, 0.55)


func _apply_style(button: Button, bg: Color, border: Color) -> void:
	for state in ["normal", "hover", "pressed"]:
		var box := StyleBoxFlat.new()
		box.bg_color = bg
		box.border_color = border
		box.set_border_width_all(2)
		box.set_corner_radius_all(0)
		if state == "hover":
			box.border_color = border.lightened(0.4)
		button.add_theme_stylebox_override(state, box)


func _update_status() -> void:
	_status.text = "Pairs %d/%d     Mistakes %d/%d" % [
		_matched_pairs, pair_count, _mistakes, max_mistakes
	]
