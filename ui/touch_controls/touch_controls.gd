extends CanvasLayer

# Touch Controls HUD
# The Button nodes are VISUAL ONLY (mouse_filter = ignore). All input is handled
# manually from raw touch events so multiple buttons can be held at once
# (e.g. move + jump, or later move + jump + grapple). Relying on Button's own
# click handling routes everything through a single emulated mouse cursor, which
# makes multi-touch impossible — hence we track each finger by its own index.
# Each finger that lands on a button injects the matching InputAction; lifting
# that finger releases it. Touches that miss every button fall through to the
# grapple (player/grapple/grapple.gd).
# On desktop "emulate_touch_from_mouse" turns the mouse into a touch with index 0,
# so the exact same code path works for PC testing.
# HUD auto-hides while the game is paused.

@export var force_show_on_desktop: bool = false

@onready var _control := $Control as Control
@onready var _btn_left  := $Control/BtnLeft  as Button
@onready var _btn_right := $Control/BtnRight as Button
@onready var _btn_jump  := $Control/BtnJump  as Button
@onready var _btn_down  := $Control/BtnDown  as Button
@onready var _btn_pause := $Control/BtnPause as Button

var _enabled := false

# Button -> input action name. Order matters only for overlap (none here).
var _button_actions := {}

# Which action each active finger is currently holding: { finger_index: action }.
var _finger_actions := {}

# Cached normal/pressed styles, swapped to show the "pressed" look while held.
var _styles := {}  # { Button: { "normal": StyleBox, "pressed": StyleBox } }

# Kept as a member so the font stays referenced — freeing a SystemFont while it is
# still the active font triggers a "Parameter fd is null" text-shaping error.
var _vi_font: SystemFont


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	var is_mobile := OS.has_feature("mobile") or OS.has_feature("android") or OS.has_feature("ios")
	if not is_mobile and not force_show_on_desktop:
		visible = false
		set_process(false)
		set_process_input(false)
		return

	_enabled = true
	_button_actions = {
		_btn_left: "left",
		_btn_right: "right",
		_btn_jump: "jump",
		_btn_down: "down",
		_btn_pause: "pause",
	}
	# Buttons are visual only — never let them swallow or process input themselves,
	# otherwise they'd consume touches through the single-cursor mouse path.
	for btn in _button_actions:
		(btn as Button).mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Nút NHẢY là nút duy nhất có chữ (các nút khác dùng ký hiệu < > v II).
	# Font hệ thống vì font pixel của theme không có dấu tiếng Việt.
	_vi_font = SystemFont.new()
	_vi_font.font_names = ["Arial", "Segoe UI", "sans-serif"]
	_btn_jump.add_theme_font_override("font", _vi_font)
	_btn_jump.add_theme_font_size_override("font_size", 8)
	_btn_jump.text = "NHẢY"

	for btn in [_btn_left, _btn_right, _btn_jump, _btn_down]:
		_styles[btn] = {
			"normal": btn.get_theme_stylebox("normal"),
			"pressed": btn.get_theme_stylebox("pressed"),
		}


func _process(_delta: float) -> void:
	if not _enabled:
		return
	# Hide controls while paused so the pause menu isn't covered by them.
	var paused := get_tree().paused
	_control.visible = not paused
	if paused:
		# While paused _input() ignores events, so a finger lifted inside the pause
		# menu would never send its "release" — release everything now to avoid a
		# button (e.g. "right") getting stuck held when the game resumes.
		if not _finger_actions.is_empty():
			_release_all()
		return
	# Keep each button's look in sync with whether its action is currently active.
	for btn in [_btn_left, _btn_right, _btn_jump, _btn_down]:
		_sync_visual(btn, _button_actions[btn])


func _release_all() -> void:
	for idx in _finger_actions:
		_send_action(_finger_actions[idx], false)
	_finger_actions.clear()


func _sync_visual(btn: Button, action: String) -> void:
	var styles: Dictionary = _styles[btn]
	var target: StyleBox = styles["pressed"] if Input.is_action_pressed(action) else styles["normal"]
	btn.add_theme_stylebox_override("normal", target)
	btn.add_theme_stylebox_override("hover", target)


# Handle each finger independently so several buttons can be held at once.
func _input(event: InputEvent) -> void:
	if not _enabled or get_tree().paused:
		return

	if event is InputEventScreenTouch:
		if event.pressed:
			_on_finger_down(event.index, event.position)
		else:
			_on_finger_up(event.index)
	elif event is InputEventScreenDrag:
		# A finger slid from one button to another (or off the buttons entirely).
		_on_finger_moved(event.index, event.position)


func _on_finger_down(index: int, pos: Vector2) -> void:
	var btn := _button_at(pos)
	if btn == null:
		return  # not on a button -> let it fall through to grapple aiming
	var action: String = _button_actions[btn]
	if action == "pause":
		_send_action("pause", true)
		# Don't track the pause finger; it's a one-shot toggle.
		get_viewport().set_input_as_handled()
		return
	_finger_actions[index] = action
	_send_action(action, true)
	get_viewport().set_input_as_handled()


func _on_finger_up(index: int) -> void:
	if _finger_actions.has(index):
		_send_action(_finger_actions[index], false)
		_finger_actions.erase(index)


func _on_finger_moved(index: int, pos: Vector2) -> void:
	var old_action: String = _finger_actions.get(index, "")
	var btn := _button_at(pos)
	var new_action: String = _button_actions[btn] if (btn != null and _button_actions[btn] != "pause") else ""
	if new_action == old_action:
		return
	# Released the old button (slid off / onto a different one).
	if old_action != "":
		_send_action(old_action, false)
		_finger_actions.erase(index)
	# Pressed a new directional/jump button.
	if new_action != "":
		_finger_actions[index] = new_action
		_send_action(new_action, true)


# Returns the visual button whose rect contains pos, or null.
func _button_at(pos: Vector2) -> Button:
	for btn in _button_actions:
		var b := btn as Button
		if b.visible and b.get_global_rect().has_point(pos):
			return b
	return null


func _send_action(action: String, pressed: bool) -> void:
	var ev := InputEventAction.new()
	ev.action = action
	ev.pressed = pressed
	Input.parse_input_event(ev)
