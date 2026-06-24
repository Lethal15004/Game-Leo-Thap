extends CanvasLayer

@export var sample_sounds: Array[AudioStream] = []
@export var _fast_sound: AudioStream
@export var _slow_sound: AudioStream

var _is_paused := false
var _tweening := false
var master_bus := AudioServer.get_bus_index("Master")
var music_bus := AudioServer.get_bus_index("Music")
var sound_bus := AudioServer.get_bus_index("Sounds")
var voices_bus := AudioServer.get_bus_index("Voices")

var _player : Player
var _player_hitbox : Area2D
var _vi_font : SystemFont

# Game toàn tiếng Việt: [node path tương đối $Control/VBoxContainer] = text VI
const UI_LABELS := {
	"Label3": "Âm lượng:",
	"VolumeGrid/MasterLabel": "Chính",
	"VolumeGrid/MusicLabel": "Nhạc",
	"VolumeGrid/SoundsLabel": "Tiếng",
	"VolumeGrid/VoicesLabel": "Giọng",
	"Label4": "Hỗ trợ:",
	"AssistGrid/LongGrappleLabel": "Móc dài",
	"AssistGrid/SlowModeLabel": "Chậm lại",
	"AssistGrid/InvinsibilityLabel": "Bất tử",
}
const VI_FONT_SIZE := 11
const VI_TITLE_FONT_SIZE := 12

# Tiêu đề section dùng font size lớn hơn 1 chút
const TITLE_LABEL_PATHS := [
	"Label3",
	"Label4",
]

@onready var _control := $Control


func _ready() -> void:
	visible = false
	_player = get_tree().get_first_node_in_group("player") as Player
	_player_hitbox = _player.get_node("Hitbox") as Area2D
	($Control/VBoxContainer/AssistGrid/long_grapple_check as CheckBox).button_pressed = GameState.long_grapple
	($Control/VBoxContainer/AssistGrid/slow_mode_check as CheckBox).button_pressed = GameState.slow_mode
	($Control/VBoxContainer/AssistGrid/invinsibility_check as CheckBox).button_pressed = GameState.invinsible
	($Control/VBoxContainer/VolumeGrid/master_slider as HSlider).value = AudioServer.get_bus_volume_db(master_bus)
	($Control/VBoxContainer/VolumeGrid/music_slider as HSlider).value = AudioServer.get_bus_volume_db(music_bus)
	($Control/VBoxContainer/VolumeGrid/sounds_slider as HSlider).value = AudioServer.get_bus_volume_db(sound_bus)
	($Control/VBoxContainer/VolumeGrid/voices_slider as HSlider).value = AudioServer.get_bus_volume_db(voices_bus)
	var kiwi_label := $Control.get_node_or_null("Label2") as Label
	if kiwi_label:
		kiwi_label.visible = false
	_vi_font = SystemFont.new()
	_vi_font.font_names = ["Arial", "Segoe UI", "sans-serif"]
	_apply_vietnamese()


# Set toàn bộ label menu sang tiếng Việt một lần (game không còn toggle ngôn ngữ).
# Font hệ thống vì font pixel KiwiSoda không có dấu.
func _apply_vietnamese() -> void:
	var root_vbox := $Control/VBoxContainer
	for path in UI_LABELS:
		var lbl := root_vbox.get_node_or_null(path) as Label
		if lbl == null:
			continue
		lbl.text = UI_LABELS[path]
		var size := VI_TITLE_FONT_SIZE if path in TITLE_LABEL_PATHS else VI_FONT_SIZE
		lbl.add_theme_font_override("font", _vi_font)
		lbl.add_theme_font_size_override("font_size", size)

	# Tiêu đề game "Leo Tháp" (có dấu nên cũng phải dùng font hệ thống).
	var title := root_vbox.get_node_or_null("RichTextLabel") as Label
	if title:
		title.text = "Leo Tháp"
		title.add_theme_font_override("font", _vi_font)


func _unhandled_input(event: InputEvent):
	if event.is_action_pressed("pause") and not _tweening:
		if not _is_paused and ScreenFade.is_faded():
			return
		_is_paused = not _is_paused
		SoundController.play(_slow_sound if _is_paused else _fast_sound, -12, 0.4)
		_tweening = true
		if _is_paused:
			DialogueController.visible = false
			get_tree().paused = true
			_control.modulate = Color.TRANSPARENT
			visible = true
			ScreenFade.set_circle(0.075, 0.5)
			await ScreenFade.done
			var tween = create_tween()
			tween.tween_property(_control, "modulate", Color.WHITE, 0.25)
			tween.tween_callback(func(): _tweening = false)
		else:
			_control.modulate = Color.WHITE
			var tween = create_tween()
			tween.tween_property(_control, "modulate", Color.TRANSPARENT, 0.25)
			await tween.finished
			visible = false
			ScreenFade.set_circle(1.0, 0.5)
			await ScreenFade.done
			_tweening = false
			DialogueController.visible = true
			get_tree().paused = false


func _on_master_slider_value_changed(value):
	AudioServer.set_bus_volume_db(master_bus, value)


func _on_music_slider_value_changed(value):
	AudioServer.set_bus_volume_db(music_bus, value)


func _on_sounds_slider_value_changed(value):
	AudioServer.set_bus_volume_db(sound_bus, value)


func _on_voices_slider_value_changed(value):
	AudioServer.set_bus_volume_db(voices_bus, value)


func _on_long_grapple_check_toggled(toggled_on):
	_player._grapple.grapple_length = 10 if toggled_on else 5
	GameState.long_grapple = toggled_on


func _on_invinsibility_check_toggled(toggled_on):
	_player_hitbox.set_collision_mask_value(5, not toggled_on)
	GameState.invinsible = toggled_on


func _on_slow_mode_check_toggled(toggled_on):
	Engine.time_scale = 0.5 if toggled_on else 1.0
	GameState.slow_mode = toggled_on


func _on_btn_close_pressed() -> void:
	var ev := InputEventAction.new()
	ev.action = "pause"
	ev.pressed = true
	Input.parse_input_event(ev)
