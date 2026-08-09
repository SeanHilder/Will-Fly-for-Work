class_name InteractionPrompt extends Node2D
## Floating key prompt ("press E") for interactables.
##
## Drop the interaction_prompt.tscn scene under any Interactable (Area2D) and
## it pops in whenever an Interactor comes into range, pops out when they
## leave. Position it in the editor (usually above the NPC's head).

## The area whose range triggers the prompt. Leave empty to use the parent.
@export var interactable: Area2D

var _tween: Tween


func _ready() -> void:
	if interactable == null:
		interactable = get_parent() as Area2D
	if interactable == null:
		push_warning("InteractionPrompt: no Area2D to watch (parent is '%s')" % get_parent().name)
		return

	interactable.area_entered.connect(_on_area_entered)
	interactable.area_exited.connect(_on_area_exited)
	visible = false
	scale = Vector2.ZERO


func _on_area_entered(area: Area2D) -> void:
	if area is Interactor:
		_pop(true)


func _on_area_exited(area: Area2D) -> void:
	if area is Interactor:
		_pop(false)


func _pop(shown: bool) -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	if shown:
		visible = true
		_tween.tween_property(self, "scale", Vector2.ONE, 0.18) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	else:
		_tween.tween_property(self, "scale", Vector2.ZERO, 0.12) \
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		_tween.tween_callback(func() -> void: visible = false)
