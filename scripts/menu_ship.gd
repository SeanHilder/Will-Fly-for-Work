extends ColorRect

@export var travel_time: float = 8.0
@export var pause_between: float = 5.0
@export var center_x: float = 576.0
@export var start_y: float = 640.0
@export var end_y: float = 300.0
@export var start_size: float = 150.0
@export var end_size: float = 26.0
@export var fade_start: float = 0.55

var _elapsed: float = 0.0


func _process(delta: float) -> void:
	_elapsed += delta
	var local := fmod(_elapsed, travel_time + pause_between)

	if local > travel_time:
		visible = false
		return
	visible = true

	var f := local / travel_time

	# hyperbolic falloff — how apparent size actually shrinks with distance
	var k := start_size / end_size - 1.0
	var s := start_size / (1.0 + k * f)

	size = Vector2(s, s)
	position = Vector2(center_x - s * 0.5, lerpf(start_y, end_y, f) - s * 0.5)

	var fade := clampf((f - fade_start) / (1.0 - fade_start), 0.0, 1.0)
	modulate.a = 1.0 - fade * fade
