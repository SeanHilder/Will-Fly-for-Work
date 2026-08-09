class_name HoverBob extends Sprite2D
## Gentle sine bob for floating sprites (hover bots, pickups).
## Attach to the visual sprite only — the parent's collision stays put, and
## any ground-shadow sibling stays on the ground, which sells the float.

@export var amplitude := 5.0
@export var speed := 2.5

var _base_y := 0.0
var _t := 0.0


func _ready() -> void:
	_base_y = position.y
	_t = randf() * TAU  # multiple bots shouldn't bob in sync


func _process(delta: float) -> void:
	_t += delta * speed
	position.y = _base_y + sin(_t) * amplitude
