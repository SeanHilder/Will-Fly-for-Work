class_name DialogBox extends Control

@export var is_on : bool = false
@export var text : Label
@export var scroll_duration : float = 1.0
## Optional speaker name tag; older scenes without it keep working.
@export var name_label : Label

var text_scroll_tween : Tween

func _ready():
	is_on = false

## Shows a line with a speaker name tag. Color tints the name so speakers
## are recognizable at a glance. Empty speaker hides the tag.
func set_line(speaker : String, val : String, name_color : Color = Color.WHITE):
	if name_label:
		name_label.get_parent().visible = speaker != ""
		name_label.text = speaker
		name_label.add_theme_color_override("font_color", name_color)
	set_text(val)

func set_text(val : String):
	text.text = val
	
	if text_scroll_tween:
		text_scroll_tween.kill()
		
	text_scroll_tween = create_tween()
	text_scroll_tween.tween_callback(
		func():
			text.visible_ratio = 0.0
	)
	text_scroll_tween.tween_property(
		text,
		"visible_ratio",
		1.0,
		scroll_duration
	)
	
