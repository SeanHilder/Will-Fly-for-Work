class_name StoryDialogInteractable extends DialogInteractable
## DialogInteractable with speakers. Write dialog_lines as "Speaker|text":
##
##   "JOBB-E|Scanning... oh dear."
##   "YOU|Rude."
##
## The speaker name shows in the dialog box's name tag, tinted with the color
## from speaker_colors, so it's obvious who's talking. Lines without "|" show
## no tag (narration).

## Speaker name -> name-tag color, e.g. {"JOBB-E": Color.CYAN}.
@export var speaker_colors := {}


func _advance_dialog():
	if _current_line_index == -1:
		dialog_box.is_on = true

	if _current_line_index >= dialog_lines.size() - 1:
		dialog_box.is_on = false
		_current_line_index = -1
		return

	_current_line_index += 1
	var line: String = dialog_lines[_current_line_index]
	var speaker := ""
	var text := line
	var sep := line.find("|")
	if sep != -1:
		speaker = line.substr(0, sep)
		text = line.substr(sep + 1)
	dialog_box.set_line(speaker, text, speaker_colors.get(speaker, Color.WHITE))
