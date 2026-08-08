class_name VetPatient extends Grabbable
## VetPatient — a tumbling zero-g creature that must be treated.
##
## Built on top of A's Grabbable (grab/release/momentum already handled
## there). This script adds the Level 1 specific behaviour:
##   - spawns tumbling (random velocity + spin), gravity_scale should be 0
##     on the node itself (set in the .tscn) so it never settles.
##   - state machine: IDLE -> THRASHING. Thrashing patients fling themselves
##     with random impulses (escalation hook calls start_thrashing()).
##   - a child Area2D named "TreatZone" detects TreatmentItem instances that
##     are actively held nearby and fills `treatment_progress` over time.
##
## Level script API:
##   - spawn_tumbling(velocity: Vector2, angular_velocity: float)
##   - start_thrashing() / stop_thrashing()
##   - signal treated() — emitted once, when treatment_progress reaches 1.0

enum State { IDLE, THRASHING, TREATED }

signal treated

## Seconds of item-in-zone contact needed to fully treat the patient.
@export var treat_time := 3.0

## Impulse strength applied to itself while thrashing.
@export var thrash_impulse_min := 120.0
@export var thrash_impulse_max := 260.0

## How often (seconds) a thrashing patient fires an impulse.
@export var thrash_interval_min := 0.4
@export var thrash_interval_max := 1.0

@onready var _treat_zone: Area2D = $TreatZone
@onready var _thrash_timer: Timer = $ThrashTimer

var state: State = State.IDLE
var treatment_progress := 0.0

var _items_in_zone: Array[TreatmentItem] = []


func _ready() -> void:
	_treat_zone.body_entered.connect(_on_treat_zone_body_entered)
	_treat_zone.body_exited.connect(_on_treat_zone_body_exited)
	_thrash_timer.timeout.connect(_on_thrash_timer_timeout)


func _physics_process(delta: float) -> void:
	# Let Grabbable run its held-lerp behaviour first (this override would
	# otherwise replace it entirely).
	super._physics_process(delta)

	if is_held() or state == State.TREATED:
		return

	if _items_in_zone.is_empty():
		return

	for item in _items_in_zone:
		if is_instance_valid(item) and item.is_held():
			_add_treatment_progress(delta / treat_time)
			break  # one item's worth of progress per frame is enough


## Called by the level to send the patient drifting in at shift start or
## whenever escalation spawns a new one.
func spawn_tumbling(velocity: Vector2, angular_velocity_value: float) -> void:
	linear_velocity = velocity
	angular_velocity = angular_velocity_value


func start_thrashing() -> void:
	if state == State.TREATED:
		return
	state = State.THRASHING
	_thrash_timer.wait_time = randf_range(thrash_interval_min, thrash_interval_max)
	_thrash_timer.start()


func stop_thrashing() -> void:
	if state == State.THRASHING:
		state = State.IDLE
	_thrash_timer.stop()


func _add_treatment_progress(amount: float) -> void:
	treatment_progress = clampf(treatment_progress + amount, 0.0, 1.0)
	if treatment_progress >= 1.0 and state != State.TREATED:
		state = State.TREATED
		stop_thrashing()
		modulate = Color(0.6, 1.0, 0.6, 1.0)  # placeholder "calm/treated" tint
		treated.emit()


func _on_thrash_timer_timeout() -> void:
	if state != State.THRASHING or is_held():
		_thrash_timer.start(randf_range(thrash_interval_min, thrash_interval_max))
		return

	var impulse := Vector2.RIGHT.rotated(randf() * TAU) * randf_range(thrash_impulse_min, thrash_impulse_max)
	apply_impulse(impulse)
	angular_velocity += randf_range(-6.0, 6.0)
	_thrash_timer.start(randf_range(thrash_interval_min, thrash_interval_max))


func _on_treat_zone_body_entered(body: Node) -> void:
	if body == self:
		return
	if body is TreatmentItem:
		_items_in_zone.append(body)


func _on_treat_zone_body_exited(body: Node) -> void:
	if body is TreatmentItem:
		_items_in_zone.erase(body)
