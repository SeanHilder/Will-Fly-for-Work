class_name Grabbable extends RigidBody2D
## Grabbable — a physics object that can be picked up with click-drag.
##
## Used together with GrabController (player input). While held, physics is
## frozen and the object eases toward the target point the controller pushes
## each frame. On release, simulation resumes with the controller-provided
## linear and angular velocity — momentum is preserved, which is the core
## zero-g feel every level builds on.
##
## Setup in the scene:
##   - Physics layer: "Dynamic Object" (5)
##   - Keep friction / bounce low (friction 0) so released objects keep
##     drifting instead of stopping instantly.
##
## API for level authors:
##   - grab(grab_offset := Vector2.ZERO)      — pick up
##   - update_target(target: Vector2)         — called while held to steer it
##   - release(velocity: Vector2, angular_velocity: float) — let go
##   - is_held() -> bool
##   - signals on_grabbed() / on_released()

signal on_grabbed
signal on_released

## How quickly the object snaps toward the cursor while held (higher = snappier).
@export var grab_smoothing := 18.0

## While held the object may rotate to match the drag motion if true.
## Off by default for the MVP: rotation is preserved until release.
@export var match_rotation_while_held := false

var _is_held := false
var _grab_offset := Vector2.ZERO
var _target_position := Vector2.ZERO
var _target_rotation := 0.0


func _physics_process(delta: float) -> void:
	if not _is_held:
		return

	var target := _target_position + _grab_offset
	global_position = global_position.lerp(target, 1.0 - exp(-grab_smoothing * delta))

	if match_rotation_while_held:
		rotation = lerp_angle(rotation, _target_rotation, 1.0 - exp(-grab_smoothing * delta))


## Pick the object up. `grab_offset` is the vector from the cursor/grab point
## to the object's origin, captured at grab time so the object doesn't jump.
func grab(grab_offset := Vector2.ZERO) -> void:
	if _is_held:
		return

	_is_held = true
	_grab_offset = grab_offset
	_target_position = global_position
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	freeze = true
	on_grabbed.emit()


## Steer the held object toward a world position (usually the cursor).
## Smoothing happens inside so callers can push the raw target each frame.
func update_target(target: Vector2) -> void:
	if _is_held:
		_target_position = target


## Intended target rotation while held (used with match_rotation_while_held).
func update_target_rotation(target_rotation: float) -> void:
	if _is_held:
		_target_rotation = target_rotation


## Let go. `velocity` and `angular_velocity` are what the controller measured
## from the cursor's recent motion — the object keeps flying with that
## momentum once physics resumes.
func release(velocity: Vector2, angular_velocity_value: float) -> void:
	if not _is_held:
		return

	_is_held = false
	freeze = false
	linear_velocity = velocity
	angular_velocity = clampf(angular_velocity_value, -15.0, 15.0)
	on_released.emit()


func is_held() -> bool:
	return _is_held
