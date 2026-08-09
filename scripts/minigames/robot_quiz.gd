extends Control

## Robot Recalibration Exam — Cinderon-3's job, a standalone scene.
## The maintenance robots got sun-scrambled; re-teach them computer science.
## 3 questions drawn at random from a pool of 10, answers shuffled.
## All 3 right -> asteroid blaster. One wrong -> recalibration failed, retry
## (with a fresh draw, so memorizing one run doesn't trivialize the next).

const RETURN_SCENE := "res://scenes/world_hub/cinderon.tscn"
const SELF_SCENE := "res://scenes/minigames/robot_quiz.tscn"

const QUESTIONS_PER_EXAM := 3

# "q" = question, "a" = answers with the CORRECT ONE FIRST (shuffled on display).
const POOL := [
	{
		"q": "Which data structure is First-In-First-Out (FIFO)?",
		"a": ["Queue", "Stack", "Binary tree", "Hash map"],
	},
	{
		"q": "Which data structure is Last-In-First-Out (LIFO)?",
		"a": ["Stack", "Queue", "Linked list", "Graph"],
	},
	{
		"q": "What is the time complexity of binary search on a sorted array?",
		"a": ["O(log n)", "O(n)", "O(n log n)", "O(1)"],
	},
	{
		"q": "What is the average-case time complexity of quicksort?",
		"a": ["O(n log n)", "O(n^2)", "O(log n)", "O(n)"],
	},
	{
		"q": "Which structure offers O(1) average-case lookup by key?",
		"a": ["Hash map", "Sorted array", "Binary search tree", "Linked list"],
	},
	{
		"q": "Which tree traversal visits the root BEFORE its children?",
		"a": ["Pre-order", "Post-order", "In-order", "Level-order"],
	},
	{
		"q": "Which algorithm finds shortest paths with non-negative edge weights?",
		"a": ["Dijkstra's", "Bubble sort", "Binary search", "Depth-first search"],
	},
	{
		"q": "What is the worst-case time complexity of bubble sort?",
		"a": ["O(n^2)", "O(n log n)", "O(n)", "O(log n)"],
	},
	{
		"q": "A binary tree where left < node < right for every node is called?",
		"a": ["Binary search tree", "Heap", "Trie", "Balanced queue"],
	},
	{
		"q": "Inserting at the HEAD of a singly linked list costs?",
		"a": ["O(1)", "O(n)", "O(log n)", "O(n^2)"],
	},
]

const ROBOT_TEX := preload("res://sprites/characters/hover_bot.png")

var _exam: Array = []
var _index := 0
var _answering := true

var _progress: Label
var _question: Label
var _feedback: Label
var _answer_buttons: Array[Button] = []


func _ready() -> void:
	var bg := ColorRect.new()
	bg.color = Color(0.12, 0.06, 0.05)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var heading := Label.new()
	heading.text = "ROBOT RECALIBRATION EXAM 7-C"
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.add_theme_font_size_override("font_size", 34)
	heading.add_theme_color_override("font_color", Color("ffc861"))
	heading.set_anchors_preset(Control.PRESET_TOP_WIDE)
	heading.offset_top = 22.0
	add_child(heading)

	# The patient: a sun-scrambled bot, tilted and sickly.
	var robot := Sprite2D.new()
	robot.texture = ROBOT_TEX
	robot.scale = Vector2(5, 5)
	robot.rotation = 0.35
	robot.modulate = Color(0.85, 0.75, 0.7)
	robot.position = Vector2(size.x / 2.0 if size.x > 0 else 576.0, 130.0)
	add_child(robot)

	_progress = Label.new()
	_progress.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_progress.add_theme_font_size_override("font_size", 20)
	_progress.add_theme_color_override("font_color", Color("9fb8d8"))
	_progress.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_progress.offset_top = 196.0
	add_child(_progress)

	_question = Label.new()
	_question.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_question.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_question.add_theme_font_size_override("font_size", 24)
	_question.add_theme_color_override("font_color", Color.WHITE)
	_question.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_question.offset_top = 232.0
	_question.offset_left = 160.0
	_question.offset_right = -160.0
	add_child(_question)

	var buttons_anchor := Control.new()
	buttons_anchor.set_anchors_preset(Control.PRESET_TOP_WIDE)
	buttons_anchor.offset_top = 320.0
	add_child(buttons_anchor)

	var buttons := VBoxContainer.new()
	buttons.add_theme_constant_override("separation", 10)
	buttons.set_anchors_preset(Control.PRESET_TOP_WIDE)
	buttons.offset_left = 300.0
	buttons.offset_right = -300.0
	buttons_anchor.add_child(buttons)

	for i in 4:
		var b := Button.new()
		b.custom_minimum_size = Vector2(0, 52)
		b.add_theme_font_size_override("font_size", 19)
		buttons.add_child(b)
		_answer_buttons.append(b)

	_feedback = Label.new()
	_feedback.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_feedback.add_theme_font_size_override("font_size", 17)
	_feedback.add_theme_color_override("font_color", Color(0.65, 0.6, 0.55))
	_feedback.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_feedback.offset_top = -46.0
	add_child(_feedback)
	_feedback.text = "The robot watches you with one flickering eye. No pressure."

	# Fresh random draw every attempt.
	var pool := POOL.duplicate()
	pool.shuffle()
	_exam = pool.slice(0, QUESTIONS_PER_EXAM)
	_show_question()


func _show_question() -> void:
	_answering = true
	var entry: Dictionary = _exam[_index]
	_progress.text = "QUESTION %d / %d" % [_index + 1, QUESTIONS_PER_EXAM]
	_question.text = entry.q

	# answers[0] is correct; shuffle display order.
	var order := [0, 1, 2, 3]
	order.shuffle()
	for i in 4:
		var b := _answer_buttons[i]
		var answer_index: int = order[i]
		b.text = entry.a[answer_index]
		b.disabled = false
		for conn in b.pressed.get_connections():
			b.pressed.disconnect(conn.callable)
		b.pressed.connect(_on_answer.bind(answer_index == 0))


func _on_answer(correct: bool) -> void:
	if not _answering:
		return
	_answering = false
	for b in _answer_buttons:
		b.disabled = true

	if correct:
		_index += 1
		if _index >= QUESTIONS_PER_EXAM:
			_win()
		else:
			_feedback.text = "CORRECT. Neural weights adjusted. The robot hums approvingly."
			get_tree().create_timer(0.9).timeout.connect(_show_question)
	else:
		_fail()


func _win() -> void:
	GameState.grant_part(&"asteroid_blaster")
	GameState.save_progress()
	_progress.text = "RECALIBRATION COMPLETE"
	_question.text = "The robot reboots and immediately un-sorts VOLT's horoscope filing system.\nPAYMENT: ONE (1) ASTEROID BLASTER."
	_feedback.text = "Certified. Reluctantly."
	get_tree().create_timer(2.2).timeout.connect(func() -> void:
		SceneTransitionManager.change_scene_with_transition(
			load(RETURN_SCENE),
			load(GameManager.TRANSITION_PATH)
		)
	)


func _fail() -> void:
	_progress.text = "RECALIBRATION FAILED"
	_question.text = "The robot now believes bubble sort is a lifestyle."
	_feedback.text = "VOLT insists you try again. New questions. Immediately."
	get_tree().create_timer(1.8).timeout.connect(func() -> void:
		SceneTransitionManager.change_scene_with_transition(
			load(SELF_SCENE),
			load(GameManager.TRANSITION_PATH)
		)
	)
