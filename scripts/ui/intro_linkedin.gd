extends Control
## Intro cutscene: a parody job site ("WorkedIn") drowns the player in AI
## rejection notifications, then dangles the one job the algorithms won't
## touch. APPLY → world hub.
##
## Flow: quiet feed → rejections stack up faster and faster → empty feed
## ("0 jobs match your profile") → the offer + APPLY button.
## Click anywhere to jump straight to the offer; Esc leaves for the hub.
##
## Standalone-safe: the hub never depends on this scene having run.

enum Phase { FEED, EMPTY, OFFER, LEAVING }

const REJECTIONS: Array[String] = [
	"Warehouse Picker — position filled by TaskOptimizer-9.",
	"Barista — automated. The foam art is 'objectively better' now.",
	"Dog Walker — replaced by drone swarm. The dogs seem fine.",
	"Accountant — position deleted. So was the department.",
	"Teacher — curriculum is now self-teaching.",
	"Chef — kitchen optimized. Flavor deemed a legacy feature.",
	"Therapist — patients rerouted to EmpathyEngine(tm), beta.",
	"Astronaut — the ship flies itself. It asked us to stop calling.",
	"Poet — rejected in iambic pentameter.",
	"Firefighter — fires now prevented at the source.",
	"Middle Manager — nothing left to manage.",
	"CEO — the board elected a spreadsheet.",
]

const OFFER_TEXT := "1 job found.
Category: biological chaos.
Location: [color=#1f5c9e][url=map]Ataraxia[/url][/color].
Hazard pay: emotionally, yes."

## Seconds before the first rejection lands.
@export var start_delay := 1.2
## Gap between the first two rejections; every gap after shrinks by gap_falloff.
@export var first_gap := 2.4
@export var gap_falloff := 0.92
@export var min_gap := 0.4
## Feed keeps at most this many notifications on screen.
@export var max_visible := 7

@onready var _feed: VBoxContainer = %Feed
@onready var _status_label: Label = %StatusLabel
@onready var _apply_button: Button = %ApplyButton
@onready var _map_view: Control = %MapView
@onready var _map_back_button: Button = %MapBackButton

var _phase := Phase.FEED
var _next_index := 0
var _gap := 0.0


func _ready() -> void:
	_apply_button.visible = false
	_apply_button.pressed.connect(_leave)
	_map_view.visible = false
	_map_back_button.pressed.connect(_close_map)
	_status_label.text = "Refreshing job feed..."
	_gap = first_gap
	get_tree().create_timer(start_delay).timeout.connect(_spawn_next)


func _unhandled_input(event: InputEvent) -> void:
	if _phase == Phase.LEAVING:
		return
	if _map_view.visible:
		if event.is_action_pressed("ui_cancel"):
			_close_map()
		return
	if event.is_action_pressed("ui_cancel"):
		_leave()
	elif event is InputEventMouseButton and event.pressed:
		_show_offer()


func _spawn_next() -> void:
	if _phase != Phase.FEED:
		return
	if _next_index >= REJECTIONS.size():
		_show_empty()
		return

	_status_label.visible = false
	_push_notification(REJECTIONS[_next_index], false)
	# AudioManager.play("res://audio/notification_ping.wav")  # when an SFX lands
	_next_index += 1
	_gap = maxf(min_gap, _gap * gap_falloff)
	get_tree().create_timer(_gap).timeout.connect(_spawn_next)


func _show_empty() -> void:
	_phase = Phase.EMPTY
	_clear_feed()
	_status_label.text = "0 jobs match your profile."
	_status_label.visible = true
	get_tree().create_timer(1.8).timeout.connect(_show_offer)


func _show_offer() -> void:
	if _phase == Phase.OFFER or _phase == Phase.LEAVING:
		return
	_phase = Phase.OFFER
	_clear_feed()
	_status_label.visible = false

	var label := _push_notification(OFFER_TEXT, true)
	_apply_button.visible = true

	# Typewriter reveal on the one message that matters.
	label.set("visible_ratio", 0.0)
	create_tween().tween_property(label, "visible_ratio", 1.0, 1.2)


func _open_map() -> void:
	_map_view.visible = true


func _close_map() -> void:
	_map_view.visible = false


func _on_offer_link_clicked(_meta: Variant) -> void:
	_open_map()


func _leave() -> void:
	if _phase == Phase.LEAVING:
		return
	_phase = Phase.LEAVING
	GameManager.return_to_hub()


func _clear_feed() -> void:
	for child in _feed.get_children():
		_feed.remove_child(child)
		child.queue_free()


## Builds one notification panel, newest on top. Returns the text control so
## the caller can animate it. Highlighted (offer) notifications use a
## RichTextLabel so [url] links work; plain rejections stay cheap Labels.
func _push_notification(text: String, highlight: bool) -> Control:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.98, 0.9, 0.72) if highlight else Color(1, 1, 1)
	style.border_color = Color(0.72, 0.5, 0.15) if highlight else Color(0.16, 0.35, 0.55)
	style.border_width_left = 6
	style.set_corner_radius_all(4)
	style.content_margin_left = 12.0
	style.content_margin_right = 10.0
	style.content_margin_top = 8.0
	style.content_margin_bottom = 8.0

	var panel := PanelContainer.new()
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_theme_stylebox_override("panel", style)

	var label: Control
	if highlight:
		var rtl := RichTextLabel.new()
		rtl.bbcode_enabled = true
		rtl.text = text
		rtl.fit_content = true
		rtl.scroll_active = false
		rtl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		rtl.add_theme_color_override("default_color", Color(0.13, 0.15, 0.19))
		rtl.add_theme_font_size_override("normal_font_size", 15)
		rtl.meta_clicked.connect(_on_offer_link_clicked)
		label = rtl
	else:
		var lbl := Label.new()
		lbl.text = text
		lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		lbl.add_theme_color_override("font_color", Color(0.13, 0.15, 0.19))
		lbl.add_theme_font_size_override("font_size", 15)
		label = lbl
	panel.add_child(label)

	_feed.add_child(panel)
	_feed.move_child(panel, 0)
	while _feed.get_child_count() > max_visible:
		var oldest := _feed.get_child(_feed.get_child_count() - 1)
		_feed.remove_child(oldest)
		oldest.queue_free()

	panel.modulate.a = 0.0
	create_tween().tween_property(panel, "modulate:a", 1.0, 0.15)
	return label
