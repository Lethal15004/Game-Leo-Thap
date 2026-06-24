extends AnimatedSprite2D
class_name Checkpoint

@export var sound : AudioStream
## Người chơi vào trong bán kính này (px) thì hiện hint "máy tính là điểm lưu"
## (chỉ khi chưa lưu lần nào — DialogueController tự quyết).
@export var hint_range := 70.0

@onready var _area := $Area2D as Area2D
@onready var _timer := $GlitchTimer as Timer
var _is_on := false
var _player: Node2D = null
var _player_near := false  # edge-trigger vùng hint

func _ready() -> void:
	animation_finished.connect(_on_animation_finished)
	_area.body_entered.connect(_on_body_entered)
	_timer.timeout.connect(_on_timeout)
	_timer.start(randi_range(10, 20))


func _physics_process(_delta: float) -> void:
	# Hint điểm lưu: báo controller khi player vào/ra vùng gần checkpoint CHƯA kích hoạt.
	var near := not _is_on and _player_in_radius(hint_range)
	if near != _player_near:
		_player_near = near
		if near:
			DialogueController.notify_checkpoint_nearby()
		else:
			DialogueController.notify_checkpoint_left()


# Trả counter khi checkpoint rời tree (reload scene) để hint không bị kẹt.
func _exit_tree() -> void:
	if _player_near:
		_player_near = false
		DialogueController.notify_checkpoint_left()


func _player_in_radius(radius: float) -> bool:
	if _player == null or not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group("player") as Node2D
		if _player == null:
			return false
	return _player.global_position.distance_to(global_position) <= radius


func _on_body_entered(_body: Node2D) -> void:
	if not _is_on:
		get_tree().call_group("checkpoint", "turn_off")
		_is_on = true
		GameState.set_checkpoint(self, sound)
		# Đã lưu -> hint checkpoint biến mất vĩnh viễn.
		DialogueController.notify_checkpoint_saved()
		play("on")


func turn_off() -> void:
	if _is_on:
		_is_on = false
		play("off")

func _on_animation_finished() -> void:
	if animation == "glitch":
		play("on" if _is_on else "off")


func _on_timeout() -> void:
	if animation == "on":
		play("glitch")
	_timer.start(randi_range(10, 20))
