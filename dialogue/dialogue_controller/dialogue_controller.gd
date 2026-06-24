extends CanvasLayer

const HANDLER_COLOR := Color(0.961, 0.914, 0.749)
const FOX_COLOR := Color(0.667, 0.392, 0.302)
const NONE_COLOR := Color(0.961, 0.914, 0.749)

# Hint dạy cách giết quái, hiện 1 lần cho tới khi người chơi giết được con đầu tiên
# của loại đó. Game toàn tiếng Việt nên text để thẳng tiếng Việt, không qua dict dịch.
const HINT_STOMP := "Nhảy lên đầu quái nấm để dẫm chết nó!"
const HINT_GRAPPLE := "Bắn dây móc vào các quái khác để tiêu diệt chúng!"
# Hint checkpoint: hiện khi tới gần máy tính lưu đầu tiên, tắt vĩnh viễn sau lần lưu đầu.
const HINT_CHECKPOINT := "Những máy tính là điểm lưu của bạn."

var _queue : Array[Dialogue]
var _tween : Tween
var _vi_font : SystemFont
var _current : Dialogue = null   # dòng đang hiện trên màn hình

# Trạng thái hint quái. Hint hiện khi có ít nhất 1 quái loại đó (chưa học cách giết)
# ở gần người chơi, và tắt vĩnh viễn khi giết được 1 con loại đó.
var _hint_text := ""          # hint đang hiện ("" = không có)
var _hint_tween : Tween = null
var _stomp_hint_done := false   # đã học cách dẫm nấm
var _grapple_hint_done := false # đã học cách bắn móc quái thường
var _stomp_near := 0            # số quái dẫm-được đang ở gần
var _grapple_near := 0          # số quái phải-bắn-móc đang ở gần
var _checkpoint_hint_done := false  # đã lưu lần đầu -> hint checkpoint tắt vĩnh viễn
var _checkpoint_near := 0           # số checkpoint (chưa kích hoạt) đang ở gần

# GDScript không có kiểu Set nên dùng dictionary, bỏ qua phần value.
var _used_dialogue_set := {}

@onready var _label := $MarginContainer/Label as Label
@onready var _hint_label := $HintMargin/HintLabel as Label
@onready var _audio := $AudioStreamPlayer as AudioStreamPlayer

func _ready() -> void:
	# Font hệ thống có dấu tiếng Việt (font pixel KiwiSoda không có dấu).
	_vi_font = SystemFont.new()
	_vi_font.font_names = ["Arial", "Segoe UI", "sans-serif"]
	_label.add_theme_font_override("font", _vi_font)
	_hint_label.add_theme_font_override("font", _vi_font)


func _process_queue() -> void:
	if _queue.is_empty() or _label.modulate != Color.TRANSPARENT:
		return
	_display_dialogue(_queue.pop_front())

func _display_dialogue(dialogue: Dialogue) -> void:
	_label.modulate = Color.TRANSPARENT
	_current = dialogue
	var color: Color
	match dialogue.source:
		"handler":
			color = HANDLER_COLOR
		"fox":
			color = FOX_COLOR
		"none":
			color = NONE_COLOR
	_label.add_theme_color_override("font_color", color)
	_label.text = dialogue.text
	_audio.stream = dialogue.sound
	_audio.play()
	_tween = create_tween()
	_tween.tween_property(_label, "modulate", Color.WHITE, 0.2)
	_tween.tween_property(_label, "modulate", Color.TRANSPARENT, 0.2).set_delay(dialogue.duration if dialogue.sound == null else dialogue.sound.get_length() if dialogue.duration == 0 else dialogue.duration)
	await _tween.finished
	_current = null
	_process_queue()


func _force_clear() -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()
		_tween = create_tween()
		_tween.tween_property(_label, "modulate", Color.TRANSPARENT, 0.2)
		await _tween.finished
		_process_queue()


func queue_up(dialogues: Array[Dialogue], high_priority := false) -> void:
	var dialogues_copy = dialogues.duplicate()
	for dialogue in dialogues_copy:
		if _used_dialogue_set.has(hash(dialogue.text)):
			dialogues.erase(dialogue)
		else:
			_used_dialogue_set[hash(dialogue.text)] = null

	if high_priority:
		dialogues.append_array(_queue)
		_queue = dialogues
		_force_clear()
	else:
		_queue.append_array(dialogues)
	_process_queue()


# --- Hint quái -----------------------------------------------------------------
# Hint đếm theo tham chiếu: mỗi quái báo khi người chơi vào/ra vùng gần nó. Hint
# hiện khi còn ít nhất 1 quái loại đó (chưa bị giết) ở gần, và tắt hẳn khi người
# chơi giết được 1 con (đã học được cơ chế).
# stompable -> "nhảy lên đầu", ngược lại -> "bắn dây móc".

func notify_enemy_nearby(stompable: bool) -> void:
	if stompable:
		_stomp_near += 1
	else:
		_grapple_near += 1
	_refresh_hint()


func notify_enemy_left(stompable: bool) -> void:
	if stompable:
		_stomp_near = max(0, _stomp_near - 1)
	else:
		_grapple_near = max(0, _grapple_near - 1)
	_refresh_hint()


# Enemy gọi khi chết. Đánh dấu đã học -> hint loại đó không hiện lại nữa.
func notify_enemy_killed(stompable: bool) -> void:
	if stompable:
		_stomp_hint_done = true
		_stomp_near = 0
	else:
		_grapple_hint_done = true
		_grapple_near = 0
	_refresh_hint()


# --- Hint checkpoint ----------------------------------------------------------
# Checkpoint báo khi người chơi vào/ra vùng gần nó (khi chưa kích hoạt). Hint tắt
# vĩnh viễn ngay lần lưu đầu tiên.

func notify_checkpoint_nearby() -> void:
	_checkpoint_near += 1
	_refresh_hint()


func notify_checkpoint_left() -> void:
	_checkpoint_near = max(0, _checkpoint_near - 1)
	_refresh_hint()


func notify_checkpoint_saved() -> void:
	_checkpoint_hint_done = true
	_checkpoint_near = 0
	_refresh_hint()


# Quyết định hint nào (nếu có) đang cần hiện.
# Ưu tiên hint quái (nguy hiểm hơn), rồi mới tới hint checkpoint.
func _refresh_hint() -> void:
	var want := ""
	if _stomp_near > 0 and not _stomp_hint_done:
		want = HINT_STOMP
	elif _grapple_near > 0 and not _grapple_hint_done:
		want = HINT_GRAPPLE
	elif _checkpoint_near > 0 and not _checkpoint_hint_done:
		want = HINT_CHECKPOINT
	if want == _hint_text:
		return
	if want == "":
		_hide_hint()
	else:
		_show_hint(want)


func _show_hint(text: String) -> void:
	if _hint_text == text:
		return  # hint này đang hiện rồi
	_hint_text = text
	_hint_label.text = _hint_text
	if _hint_tween and _hint_tween.is_valid():
		_hint_tween.kill()
	_hint_tween = create_tween()
	_hint_tween.tween_property(_hint_label, "modulate", Color.WHITE, 0.25)


func _hide_hint() -> void:
	_hint_text = ""
	if _hint_tween and _hint_tween.is_valid():
		_hint_tween.kill()
	_hint_tween = create_tween()
	_hint_tween.tween_property(_hint_label, "modulate", Color.TRANSPARENT, 0.25)
