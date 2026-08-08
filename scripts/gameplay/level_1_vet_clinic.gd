extends BaseLevel
## Level 1 — Zero-G Vet Clinic (Person C).
##
## Flow: start_shift() (called after a short fake-briefing delay so the
## scene is testable standalone with F6 — the real world hub dialogue will
## call this directly once B wires it up) spawns the first tumbling patient
## and a scatter of treatment items, then counts down `shift_duration`.
## Escalation adds a patient and scatters tools every `escalation_interval`
## seconds. When the timer ends, end_shift(score) fires on_shift_completed
## for the HUD/evaluation flow.
##
## TEMP TESTING SHIM: like A's placeholder_level.gd, this also calls
## GameManager.level_completed() a couple seconds after end_shift() so the
## full hub -> level -> hub loop is testable today, before D's evaluation
## screen exists. Delete that call once D's "Next" button owns it.

const PATIENT_SCENE: PackedScene = preload("res://scenes/levels/parts/vet_patient.tscn")
const ITEM_SCENE: PackedScene = preload("res://scenes/levels/parts/treatment_item.tscn")

## Item flavor: type name -> placeholder tint (real art swaps this later).
const ITEM_KINDS := {
	"scanner": Color(0.4, 0.85, 0.95, 1.0),
	"medicine": Color(0.98, 0.65, 0.25, 1.0),
	"bandage": Color(0.88, 0.84, 0.98, 1.0),
}

@export var patients_to_treat := 3
@export var escalation_interval := 18.0
@export var room_half_size := Vector2(520, 320)
@export var base_points_per_patient := 20
@export var speed_bonus_per_second := 2

@onready var _hint_label: Label = $ui/hint_label
@onready var _escalation_timer: Timer = $EscalationTimer
@onready var _spawn_root: Node2D = $SpawnRoot

var _time_left := 0.0
var _shift_started := false
var _score := 0
var _patients_treated := 0
var _time_left_when_cleared := -1.0

var _active_patients: Array[VetPatient] = []
var _active_items: Array[TreatmentItem] = []


func _ready() -> void:
	super._ready()
	_escalation_timer.wait_time = escalation_interval
	_escalation_timer.timeout.connect(_on_escalation_timer_timeout)
	_update_hint("Zero-G Vet Clinic loading… briefing in 1 s.")
	get_tree().create_timer(1.0).timeout.connect(start_shift)


func start_shift() -> void:
	if _shift_started:
		return
	_shift_started = true
	_time_left = shift_duration
	_score = 0
	_patients_treated = 0
	_time_left_when_cleared = -1.0

	_spawn_patient()
	for item_type in ITEM_KINDS.keys():
		_spawn_item(item_type)

	_escalation_timer.start()


func _process(delta: float) -> void:
	if not _shift_started:
		return

	_time_left -= delta
	_update_hint(
		"Treated %d/%d — %d s left. Grab tools, hold them on a patient." \
		% [_patients_treated, patients_to_treat, int(ceil(max(_time_left, 0.0)))]
	)

	if _time_left <= 0.0:
		_finish_shift()


func _finish_shift() -> void:
	_shift_started = false
	_escalation_timer.stop()

	var bonus := 0
	if _time_left_when_cleared >= 0.0:
		bonus = int(_time_left_when_cleared) * speed_bonus_per_second
	_score = _patients_treated * base_points_per_patient + bonus

	_update_hint("Shift over! Treated %d/%d. Score: %d." % [_patients_treated, patients_to_treat, _score])
	end_shift(_score)

	# TEMP: see file header — remove once D's evaluation "Next" button calls
	# GameManager.level_completed() itself.
	get_tree().create_timer(2.0).timeout.connect(
		func(): GameManager.level_completed(level_id, _score)
	)


func _on_escalation_timer_timeout() -> void:
	if not _shift_started:
		return

	_spawn_patient()

	for item in _active_items:
		if is_instance_valid(item) and not item.is_held():
			var impulse := Vector2.RIGHT.rotated(randf() * TAU) * randf_range(150.0, 320.0)
			item.apply_impulse(impulse)

	var idle_patients := _active_patients.filter(
		func(p): return is_instance_valid(p) and p.state == VetPatient.State.IDLE
	)
	if not idle_patients.is_empty():
		var panicking: VetPatient = idle_patients[randi() % idle_patients.size()]
		panicking.start_thrashing()


func _spawn_patient() -> void:
	var patient: VetPatient = PATIENT_SCENE.instantiate()
	_spawn_root.add_child(patient)
	patient.global_position = _random_point_in_room()
	patient.treated.connect(_on_patient_treated.bind(patient))

	var velocity := Vector2.RIGHT.rotated(randf() * TAU) * randf_range(60.0, 160.0)
	var angular_velocity := randf_range(-3.0, 3.0)
	patient.spawn_tumbling(velocity, angular_velocity)

	_active_patients.append(patient)


func _spawn_item(item_type: String) -> void:
	var item: TreatmentItem = ITEM_SCENE.instantiate()
	_spawn_root.add_child(item)
	item.item_type = item_type
	item.modulate = ITEM_KINDS.get(item_type, Color.WHITE)
	item.global_position = _random_point_in_room()

	var velocity := Vector2.RIGHT.rotated(randf() * TAU) * randf_range(30.0, 90.0)
	item.linear_velocity = velocity
	item.angular_velocity = randf_range(-2.0, 2.0)

	_active_items.append(item)


func _on_patient_treated(patient: VetPatient) -> void:
	_patients_treated += 1
	if _patients_treated >= patients_to_treat and _time_left_when_cleared < 0.0:
		_time_left_when_cleared = max(_time_left, 0.0)


func _random_point_in_room() -> Vector2:
	var margin := 60.0
	var x := randf_range(-room_half_size.x + margin, room_half_size.x - margin)
	var y := randf_range(-room_half_size.y + margin, room_half_size.y - margin)
	return global_position + Vector2(x, y)


func _update_hint(text: String) -> void:
	if _hint_label:
		_hint_label.text = text
