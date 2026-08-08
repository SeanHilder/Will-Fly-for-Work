extends BaseLevel
## Placeholder Level 1 — Person A's test stub.
##
## Proves the whole flow works end to end: GameManager.start_level -> scene
## loads -> start_shift() after a fake briefing delay -> timer runs ->
## end_shift(score) emits on_shift_completed for the evaluation flow.
##
## Person C replaces this scene's content with the real Zero-G Vet Clinic.
## The level_id and the BaseLevel contract stay the same, so nothing else
## needs to change.

@onready var _hint_label: Label = $ui/hint_label

var _time_left := 0.0
var _shift_started := false

func _ready() -> void:
	super._ready()
	_update_hint("Placeholder Level 1. Grabbing the crate… briefing in 1 s.")
	get_tree().create_timer(1.0).timeout.connect(start_shift)


## Fakes the post-briefing kickoff. The real level starts its task queue here.
func start_shift() -> void:
	if _shift_started:
		return
	_shift_started = true
	_time_left = shift_duration


func _process(delta: float) -> void:
	if not _shift_started:
		return

	_time_left -= delta
	_update_hint("Click-drag the crate. Auto-ends in %d s." % int(ceil(_time_left)))

	if _time_left <= 0.0:
		_shift_started = false
		# Demo score; the real level computes its own. Person D's evaluation
		# screen will own this call later — here we auto-return so the whole
		# round trip (start -> shift -> score -> hub) is testable today.
		end_shift(42)
		get_tree().create_timer(2.0).timeout.connect(
			func(): GameManager.level_completed(level_id, 42)
		)


func _update_hint(text: String) -> void:
	if _hint_label:
		_hint_label.text = text
