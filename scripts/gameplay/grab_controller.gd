class_name GrabController extends Node
## GrabController — turns mouse click-drag into grab/release of Grabbables.
##
## Attach one to the level scene (or to the player). It owns all grab input:
##   - Left-click (the "shoot" action, mapped to mouse button 1) physics-picks
##     a Grabbable under the cursor and grabs it.
##   - While held, the grabbable follows the cursor with smoothing.
##   - Releasing the button lets go, passing the cursor's recent velocity and
##     angular velocity so the object keeps flying — momentum preserved.
##
## Physics picking only hits collision layer 5 ("Dynamic Object"), so NPCs,
## walls and the player can never be grabbed accidentally.
##
## API:
##   - grab_action: String — input action used to grab (default "shoot" =
##     left mouse button)
##   - held: Grabbable — the object currently held (null when free)
##   - try_grab_at(world_pos: Vector2) — pick up a grabbable at a point
##   - release_held() — let go of whatever is held

const GRAB_MASK := 1 << 4  # physics layer 5: "Dynamic Object"

## Input action that grabs/releases. "shoot" is mapped to left mouse button.
@export var grab_action := "shoot"

## How many recent cursor positions are kept to estimate release velocity.
@export var history_size := 8

## Max velocity applied on release; keeps flung objects from exploding.
@export var max_release_speed := 1800.0

var held: Grabbable = null

var _cursor_history: Array[Vector2] = []


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(grab_action):
		_cursor_history.clear()
		_attempt_grab(_cursor_world_position())
	elif event.is_action_released(grab_action):
		if held:
			_release_held()


func _physics_process(delta: float) -> void:
	if not held:
		return

	var cursor_pos := _cursor_world_position()
	held.update_target(cursor_pos)
	held.update_target_rotation(_cursor_history_direction())

	_cursor_history.append(cursor_pos)
	if _cursor_history.size() > history_size:
		_cursor_history.pop_front()


## Try to grab a Grabbable at a world position (usually the cursor).
## Returns true if something was picked up.
func try_grab_at(world_pos: Vector2) -> bool:
	if held:
		return false

	var grabbable := _pick_grabbable_at(world_pos)
	if grabbable:
		grabbable.grab(grabbable.global_position - world_pos)
		held = grabbable
		return true
	return false


## Let go of the held object, passing along measured cursor motion.
func release_held() -> void:
	if held:
		_release_held()


func _attempt_grab(world_pos: Vector2) -> void:
	try_grab_at(world_pos)


func _release_held() -> void:
	var velocity := _cursor_velocity()
	var angular_velocity := _cursor_angular_velocity()
	held.release(velocity, angular_velocity)
	held = null
	_cursor_history.clear()


## Average cursor velocity across the recent history (world units / second).
func _cursor_velocity() -> Vector2:
	if _cursor_history.size() < 2:
		return Vector2.ZERO

	var total := Vector2.ZERO
	for i in range(1, _cursor_history.size()):
		total += _cursor_history[i] - _cursor_history[i - 1]

	var per_frame := total / float(_cursor_history.size() - 1)
	var velocity := per_frame / get_physics_process_delta_time()
	return velocity.limit_length(max_release_speed)


## Rotation rate of the cursor's travel direction — flung arcs become spin.
func _cursor_angular_velocity() -> float:
	if _cursor_history.size() < 3:
		return 0.0

	var total_angle := 0.0
	for i in range(2, _cursor_history.size()):
		var current := _cursor_history[i] - _cursor_history[i - 1]
		var previous := _cursor_history[i - 1] - _cursor_history[i - 2]
		if current.length() < 1.0 or previous.length() < 1.0:
			continue
		total_angle += current.angle() - previous.angle()

	return total_angle / float(_cursor_history.size() - 2) / get_physics_process_delta_time()


## Direction of the cursor's most recent travel (for held-object rotation).
func _cursor_history_direction() -> float:
	if _cursor_history.size() < 2:
		return 0.0
	return (_cursor_history[-1] - _cursor_history[-2]).angle()


func _pick_grabbable_at(world_pos: Vector2) -> Grabbable:
	var space := get_viewport().world_2d.direct_space_state
	var query := PhysicsPointQueryParameters2D.new()
	query.position = world_pos
	query.collide_with_areas = false
	query.collide_with_bodies = true
	query.collision_mask = GRAB_MASK

	var results := space.intersect_point(query, 8)
	for result in results:
		var collider := result.get("collider") as Grabbable
		if collider and not collider.is_held():
			return collider
	return null


func _cursor_world_position() -> Vector2:
	var camera := get_viewport().get_camera_2d()
	if camera:
		return camera.get_global_mouse_position()
	return get_viewport().get_canvas_transform().affine_inverse() \
		* get_viewport().get_mouse_position()
