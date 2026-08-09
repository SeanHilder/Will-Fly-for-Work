class_name RocketMenuInteractable extends Interactable
## Rocket that opens a clickable DestinationMenu on interact.
##
## Destinations are parallel arrays (same index = same destination):
##   labels[i]         — button text
##   scene_paths[i]    — where it travels
##   required_parts[i] — GameState part id needed, "" for always available.
## Locked destinations show up disabled with the missing part in the label.

@export var menu: DestinationMenu
@export var labels: Array[String] = []
@export var scene_paths: Array[String] = []
@export var required_parts: Array[String] = []


func _on_interact(interactor: Interactor) -> void:
	super._on_interact(interactor)
	if menu == null or menu.is_open():
		return

	var options: Array = []
	for i in labels.size():
		var req := ""
		if i < required_parts.size():
			req = required_parts[i]
		var locked: bool = req != "" and not GameState.has_part(StringName(req))
		options.append({
			"label": labels[i],
			"path": scene_paths[i],
			"locked_reason": ("needs " + req.replace("_", " ")) if locked else "",
		})
	menu.open(options)
