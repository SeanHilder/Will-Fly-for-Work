class_name CharacterSheetAnimator extends Sprite2D
## 4-direction walk animation driven by the parent CharacterBody2D's velocity.
##
## Works with RPG-Maker-style character sheets (WaterNPCs_Animations.png):
## a grid of frames where each character occupies a 3-column x 4-row block —
## 3 walk frames per direction, direction rows ordered down / left / right / up.
##
## Set hframes/vframes on this Sprite2D to the sheet's full grid
## (WaterNPCs_Animations.png: hframes 12, vframes 16), then pick a character
## with block_col / block_row (0-3 each). Swapping characters is just those
## two numbers — no re-rigging.

## Which character block in the sheet (column 0-3, row 0-3).
@export var block_col := 0
@export var block_row := 0
## Walk-cycle speed, frames per second.
@export var fps := 7.0

# Middle column of a block is the standing pose; cycle steps around it.
const FRAME_SEQ := [1, 0, 1, 2]

enum { DOWN = 0, LEFT = 1, RIGHT = 2, UP = 3 }

var _dir := DOWN
var _cycle_time := 0.0

@onready var _body := get_parent() as CharacterBody2D


func _ready() -> void:
	if _body == null:
		push_warning("CharacterSheetAnimator: parent of '%s' is not a CharacterBody2D" % name)
	_set_frame(1)


func _process(delta: float) -> void:
	if _body == null:
		return

	var v := _body.velocity
	if v.length_squared() < 25.0:
		# Standing: face the last direction with the idle frame.
		_cycle_time = 0.0
		_set_frame(1)
		return

	if absf(v.x) > absf(v.y):
		_dir = RIGHT if v.x > 0.0 else LEFT
	else:
		_dir = DOWN if v.y > 0.0 else UP

	_cycle_time += delta * fps
	_set_frame(FRAME_SEQ[int(_cycle_time) % FRAME_SEQ.size()])


func _set_frame(frame_in_block: int) -> void:
	frame_coords = Vector2i(block_col * 3 + frame_in_block, block_row * 4 + _dir)
