class_name PauseMenu extends Control

const MAIN_MENU_PATH := "res://scenes/samples/main_menu.tscn"

@export var is_paused : BoolReference
## Optional; older scenes without the button keep working.
@export var main_menu_button : Button

func _enter_tree():
	is_paused.on_value_changed.connect(_on_pause_changed)

func _exit_tree():
	is_paused.on_value_changed.disconnect(_on_pause_changed)

func _ready():
	is_paused.value = false
	if main_menu_button:
		main_menu_button.pressed.connect(_on_main_menu_pressed)

func _on_main_menu_pressed():
	# Unpause first — a paused tree would freeze the scene transition.
	is_paused.value = false
	SceneTransitionManager.change_scene_with_transition(
		load(MAIN_MENU_PATH),
		load(GameManager.TRANSITION_PATH)
	)

func _input(event : InputEvent):
	if event.is_action_pressed("ui_cancel"):
		is_paused.value = !get_tree().paused

func _on_pause_changed(_old_value : bool, value : bool):
	if value:
		pause()
	else:
		resume()

func pause():
	get_tree().paused = true
	visible = true
	
func resume():
	get_tree().paused = false
	visible = false
