extends CanvasLayer

@export var _next_scene : PackedScene

var _tween: Tween
@onready var _container := $VBoxContainer
@onready var _label := $VBoxContainer/Label as Label
@onready var _no_button := $VBoxContainer/HBoxContainer/NoButton as Button
@onready var _yes_button := $VBoxContainer/HBoxContainer/YesButton as Button

func _ready() -> void:
	# Auto-fit window to screen on PC so it never overflows on small monitors.
	if not OS.has_feature("mobile") and not OS.has_feature("android") and not OS.has_feature("ios"):
		_fit_window_to_screen()

	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		get_tree().change_scene_to_packed(_next_scene)
		return

	_apply_vietnamese()
	_start_ui()


func _apply_vietnamese() -> void:
	var vi_font := SystemFont.new()
	vi_font.font_names = ["Arial", "Segoe UI", "sans-serif"]
	_label.text = "Nên dùng toàn màn hình.\nBật chế độ toàn màn hình?"
	_no_button.text = " Không cần "
	_yes_button.text = " Có chứ! "
	for ctrl in [_label, _no_button, _yes_button]:
		ctrl.add_theme_font_override("font", vi_font)
		ctrl.add_theme_font_size_override("font_size", 12)


func _fit_window_to_screen() -> void:
	var usable := DisplayServer.screen_get_usable_rect()
	# Giữ tỉ lệ 9:16 (portrait), trừ 60px cho taskbar
	var max_h: int = usable.size.y - 60
	var max_w: int = usable.size.x - 20
	# Chiều cao tối đa theo tỉ lệ 9:16 từ cả hai chiều
	var h: int = mini(max_h, int(max_w * 320.0 / 180.0))
	var w: int = int(h * 180.0 / 320.0)
	h = int(w * 320.0 / 180.0)
	DisplayServer.window_set_size(Vector2i(w, h))
	# Canh giữa màn hình
	var cx: int = usable.position.x + (usable.size.x - w) / 2
	var cy: int = usable.position.y + (usable.size.y - h) / 2
	DisplayServer.window_set_position(Vector2i(cx, cy))


func _start_ui() -> void:
	_no_button.pressed.connect(_exit.bind(false))
	_yes_button.pressed.connect(_exit.bind(true))
	_container.modulate = Color(1, 1, 1, 0)
	_tween = create_tween()
	_tween.tween_property(_container, "modulate", Color(1, 1, 1, 1), 1).set_delay(0.5)


func _exit(to_fullscreen: bool) -> void:
	
	_no_button.pressed.disconnect(_exit)
	_yes_button.pressed.disconnect(_exit)
	if to_fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	if _tween != null and _tween.is_valid():
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(_container, "modulate", Color(1, 1, 1, 0), 1)
	_tween.tween_callback(func(): ScreenFade.set_circle(0, 0, Color.BLACK); get_tree().change_scene_to_packed(_next_scene))
