extends Node
class_name GameController

# Thoại hướng dẫn hiện ngay khi vào game (chỉ còn prompt tutorial, không còn cốt truyện).
@export var _dialogues: Array[Dialogue] = []

@export var _fast_sound: AudioStream
@export var _slow_sound: AudioStream

@onready var _player := $Player as Player
@onready var _camera := $Camera as ShakingCamera2D
@onready var _player_shader := (_player.get_node("AnimatedSprite2D") as AnimatedSprite2D).material as ShaderMaterial


func _ready() -> void:
	_set_dissolve(0)
	_set_colorize(0)
	if GameState.is_checkpoint_set():
		_player.set_input_enabled(false, true)
		ScreenFade.set_circle(0, 0)
		GameState.move_player_to_checkpoint()
		_camera.position_smoothing_enabled = false
		get_tree().create_timer(0.1).timeout.connect(func(): _camera.position_smoothing_enabled = true)
		ScreenFade.set_circle(1, 1)
		_set_colorize(1)
		_set_dissolve(1)
		var tween = create_tween()
		tween.set_parallel(false)
		SoundController.play(_fast_sound, -12, 0.4)
		tween.tween_method(_set_dissolve, 1.0, 0.0, 0.4).set_delay(0.3)
		tween.tween_method(_set_colorize, 1.0, 0.0, 0.2)
		await get_tree().create_timer(0.5).timeout
		_player.set_input_enabled(true, true)
		return

	# Vào game là chơi luôn: không còn đoạn intro rơi từ trên cao + khóa input.
	ScreenFade.set_circle(0, 0, Color.BLACK)
	ScreenFade.set_circle(1, 1, Color.BLACK)
	MusicPlayer.set_volumes(1, 1, 0, 0, 0, 0, 0, 0)
	DialogueController.queue_up(_dialogues)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and (event as InputEventMouseButton).pressed:
		Input.mouse_mode = Input.MOUSE_MODE_CONFINED


func _unhandled_key_input(event: InputEvent) -> void:
	var key_event := event as InputEventKey
	if key_event.is_pressed():

		# Debug commands
		if OS.has_feature("debug"):
			match key_event.keycode:
				KEY_ESCAPE:
					if OS.get_name() != "Web":
						get_tree().quit()
				KEY_R:
					get_tree().reload_current_scene()

		# Prod commands
		match key_event.keycode:
			KEY_F11:
				if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_WINDOWED:
					DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
				else:
					DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func respawn() -> void:
	_player.freeze_position = true
	ScreenFade.set_circle(0.15, 0.75)
	TimeController.scale_time(0.01, 0.1)
	await ScreenFade.done
	SoundController.play(_slow_sound, -12, 0.4)
	var tween = create_tween()
	tween.set_parallel(false)
	tween.tween_method(_set_colorize, 0.0, 1.0, 0.0025)
	tween.tween_method(_set_dissolve, 0.0, 1.0, 0.005)
	await tween.finished

	ScreenFade.set_circle(0, 0.5)
	TimeController.scale_time(1.0 if not GameState.slow_mode else 0.5, 0.5)
	await TimeController.time_scaling_done

	get_tree().reload_current_scene()


func _set_dissolve(value: float) -> void:
	_player_shader.set_shader_parameter("sensitivity", value)


func _set_colorize(value: float) -> void:
	_player_shader.set_shader_parameter("percentage", value)


func _on_end_area_body_entered(_body):
	_player.freeze_position = true
	_player.set_input_enabled(false, false)
	ScreenFade.set_circle(0.0, 5.0)
	await ScreenFade.done
	var tween := create_tween()
	$End/Control.modulate = Color.TRANSPARENT

	var minutes := int(floor(GameState.elapsed_time / 60))
	var seconds := int(GameState.elapsed_time) % 60
	var end_label := $End/Control/VBoxContainer/Label as Label
	var time_label := $End/Control/VBoxContainer/TimeLabel as Label
	var deaths_label := $End/Control/VBoxContainer/DeathsLabel as Label
	var vi_font := SystemFont.new()
	vi_font.font_names = ["Arial", "Segoe UI", "sans-serif"]
	end_label.text = "Bạn đã leo tới đỉnh tháp!\n\nCảm ơn đã chơi Leo Tháp!"
	time_label.text = "Thời gian: %d phút %02d giây" % [minutes, seconds]
	deaths_label.text = "Số lần chết: %d" % GameState.deaths
	for lbl in [end_label, time_label, deaths_label]:
		lbl.add_theme_font_override("font", vi_font)
		lbl.add_theme_font_size_override("font_size", 12)
	$End.visible = true
	tween.tween_property($End/Control, "modulate", Color.WHITE, 2.0)
