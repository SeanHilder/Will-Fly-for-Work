extends Node

var num_players = 8
var bus = "SFX"

var available = []  # The available players.
var queue = []  # The queue of sounds to play.

## Dedicated looping player for music. Separate from the SFX pool because
## music needs to loop, persist, and sit on its own bus so the Music slider
## in the settings menu controls it independently.
var music_player: AudioStreamPlayer
var music_bus = "Music"
var music_fade_time = 0.8

var _current_music_path := ""
var _music_tween: Tween
## Stack of tracks pushed aside by push_music(), newest last.
var _music_stack: Array[String] = []


func _ready():
	# Create the pool of AudioStreamPlayer nodes.
	for i in num_players:
		var p = AudioStreamPlayer.new()
		add_child(p)
		available.append(p)
		p.finished.connect(_on_stream_finished.bind(p))
		p.bus = bus

	music_player = AudioStreamPlayer.new()
	music_player.bus = music_bus
	music_player.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(music_player)


## Starts a looping track. Calling it again with the same path does nothing,
## so it is safe to call from _ready() of every scene that wants this music.
func play_music(path: String, fade_in: bool = true) -> void:
	if path == _current_music_path and music_player.playing:
		return

	var stream = load(path)
	if stream == null:
		push_error("AudioManager: could not load music '%s'" % path)
		return

	# WAV and OGG expose looping differently; set whichever applies.
	if stream is AudioStreamWAV:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		stream.loop_begin = 0
		stream.loop_end = 0
	elif stream is AudioStreamOggVorbis or stream is AudioStreamMP3:
		stream.loop = true

	_current_music_path = path
	music_player.stream = stream

	if fade_in:
		music_player.volume_db = -40.0
		music_player.play()
		_tween_music_volume(0.0)
	else:
		music_player.volume_db = 0.0
		music_player.play()


## Fades out and stops. Pass fade_out = false to cut immediately.
func stop_music(fade_out: bool = true) -> void:
	_current_music_path = ""
	if not fade_out:
		music_player.stop()
		return
	_tween_music_volume(-40.0)
	await _music_tween.finished
	music_player.stop()


func is_music_playing() -> bool:
	return music_player != null and music_player.playing


## Temporarily swaps to another track, remembering the current one and where
## it had got to. Used by minigames so the planet's theme can resume after.
func push_music(path: String) -> void:
	if _current_music_path != "":
		_music_stack.append("%s|%f" % [_current_music_path, music_player.get_playback_position()])
	play_music(path)


## Returns to whatever push_music() interrupted, resuming from that position
## rather than restarting it. Does nothing if nothing was pushed.
func pop_music() -> void:
	if _music_stack.is_empty():
		return

	var entry: String = _music_stack.pop_back()
	var parts := entry.split("|")
	var path := parts[0]
	var at := float(parts[1]) if parts.size() > 1 else 0.0

	play_music(path)
	if music_player.playing:
		music_player.seek(at)


func _tween_music_volume(target_db: float) -> void:
	if _music_tween:
		_music_tween.kill()
	_music_tween = create_tween()
	_music_tween.tween_property(music_player, "volume_db", target_db, music_fade_time)


func _on_stream_finished(stream):
	# When finished playing a stream, make the player available again.
	available.append(stream)


func play(sound_path):
	queue.append(sound_path)


func _process(_delta):
	# Play a queued sound if any players are available.
	if not queue.is_empty() and not available.is_empty():
		available[0].stream = load(queue.pop_front())
		available[0].play()
		available.pop_front()
