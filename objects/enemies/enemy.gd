extends CharacterBody2D
class_name Enemy

# Generic enemy used for all four monster types (Mushroom, Goblin, Skeleton, Flying Eye).
#
# A single Area2D ("StompZone") covers the whole creature and detects the player
# (layer 2). On contact the enemy itself decides what happens — no race between two
# separate hitboxes:
#   * player falling AND clearly above the enemy  -> STOMP: enemy dies, player bounces.
#   * otherwise                                   -> the player dies and respawns at
#                                                    the last checkpoint (unless the
#                                                    "Invincibility" assist is on).
#
# The body itself only collides with the solid world so walkers can patrol.

const SOLID_LAYER_MASK := 1  # collide with "solid" world geometry while walking

@export_group("Sprite Sheets")
@export var idle_sheet: Texture2D
@export var idle_count: int = 4
@export var walk_sheet: Texture2D
@export var walk_count: int = 8
@export var death_sheet: Texture2D
@export var death_count: int = 4
## Attack animation, played when the player enters the attack zone (see attack_reach).
@export var attack_sheet: Texture2D
@export var attack_count: int = 8
## "Take hit" reaction, played each time the enemy is damaged but survives.
@export var hit_sheet: Texture2D
@export var hit_count: int = 4
@export var frame_size: Vector2i = Vector2i(150, 150)
@export var anim_fps: float = 10.0

@export_group("Visual")
## Scale applied to the AnimatedSprite2D (sheet frames are 150px, creatures are tiny).
@export var sprite_scale: float = 0.8
## Offset in FRAME pixels to align the creature inside the 150px frame
## (feet on the body origin for walkers, centre for flyers).
@export var sprite_offset: Vector2 = Vector2(0, -25)
## Full on-screen height of the creature in game px (drives the collider zones).
@export var visual_height: float = 30.0
## Width of the body collider in game px.
@export var body_width: float = 16.0

@export_group("Behaviour")
@export var flying: bool = false
@export var move_speed: float = 28.0
## How far the attack reaches PAST the body's edge, in px. This single value defines the
## attack zone (a box hugging the body + this reach + the player's own size): the enemy
## starts swinging when the player enters it, and the swing connects if the player is still
## inside it on attack_hit_frame. One zone for both, so "if it swings, it hits".
@export var attack_reach: float = 10.0
## Frame of the "attack" animation on which the swing actually connects (deals damage).
@export var attack_hit_frame: int = 4
## For flyers: how far (px) it drifts each way from its spawn point before turning.
@export var patrol_range: float = 50.0
@export var gravity: float = 600.0
@export var stomp_bounce: float = 260.0
## Sound played when the enemy dies (optional).
@export var stomp_sound: AudioStream

@export_group("Combat")
## Can the player kill it by jumping on its head? Mushroom = true; the others must
## be killed with the grapple hook instead.
@export var stompable: bool = true
## How close (px) the player must get for the first-time how-to-kill hint to appear.
@export var hint_range: float = 80.0
## Number of grapple-hook hits needed to kill it (0 = immune to the grapple).
## Bat = 1, Goblin = 2, Skeleton = 3.
@export var grapple_hits: int = 0

var _dir := -1.0       # -1 = facing/moving left, +1 = right
var _dead := false
var _start_x := 0.0
var _hp := 0
var _player: Node2D = null
var _reacting := false  # true while the one-shot "take hit" animation is playing
var _flash_tween: Tween = null
var _player_near := false  # tracks whether the player is inside hint_range (edge-triggered)

@onready var _sprite := $AnimatedSprite2D as AnimatedSprite2D
@onready var _body_shape := $BodyShape as CollisionShape2D
@onready var _stomp_zone := $StompZone as Area2D
@onready var _stomp_shape := $StompZone/Shape as CollisionShape2D
@onready var _ledge := $LedgeCheck as RayCast2D


func _ready() -> void:
	_start_x = global_position.x
	_hp = grapple_hits
	collision_layer = 0
	set_collision_layer_value(3, true)   # "grappleables" — so the grapple hook can hit it
	collision_mask = 0 if flying else SOLID_LAYER_MASK

	_build_sprite_frames()
	_configure_sprite()
	_configure_colliders()

	_stomp_zone.collision_layer = 0
	_stomp_zone.collision_mask = 0
	_stomp_zone.set_collision_mask_value(2, true)    # layer 2 = "player"
	_stomp_zone.body_entered.connect(_on_player_touched)
	_sprite.frame_changed.connect(_on_sprite_frame_changed)

	_face(_dir)
	_play_move_anim()


# If this enemy leaves the tree (killed or scene reloaded) while the player was inside
# its hint range, release its hold on the hint counter so it can't leak.
func _exit_tree() -> void:
	if _player_near:
		_player_near = false
		DialogueController.notify_enemy_left(stompable)


func _build_sprite_frames() -> void:
	var sf := SpriteFrames.new()
	if sf.has_animation("default"):
		sf.remove_animation("default")
	_add_anim(sf, "idle", idle_sheet, idle_count, true)
	_add_anim(sf, "walk", walk_sheet, walk_count, true)
	_add_anim(sf, "attack", attack_sheet, attack_count, true)
	_add_anim(sf, "hit", hit_sheet, hit_count, false)
	_add_anim(sf, "death", death_sheet, death_count, false)
	_sprite.sprite_frames = sf


func _add_anim(sf: SpriteFrames, anim: String, sheet: Texture2D, count: int, loop: bool) -> void:
	if sheet == null or count <= 0:
		return
	if not sf.has_animation(anim):
		sf.add_animation(anim)
	sf.set_animation_loop(anim, loop)
	sf.set_animation_speed(anim, anim_fps)
	for i in count:
		var at := AtlasTexture.new()
		at.atlas = sheet
		at.region = Rect2(i * frame_size.x, 0, frame_size.x, frame_size.y)
		sf.add_frame(anim, at)


func _configure_sprite() -> void:
	_sprite.centered = true
	_sprite.scale = Vector2(sprite_scale, sprite_scale)
	_sprite.offset = sprite_offset


func _configure_colliders() -> void:
	var h := visual_height
	var w := body_width

	# World-collision footprint (so walkers can stand and turn). Sits on the feet
	# for walkers (origin at y = 0), centred for flyers.
	var body_rect := RectangleShape2D.new()
	if flying:
		body_rect.size = Vector2(w, h)
		_body_shape.position = Vector2.ZERO
	else:
		body_rect.size = Vector2(w, h * 0.85)
		_body_shape.position = Vector2(0, -h * 0.425)
	_body_shape.shape = body_rect

	# Player sensor: covers the whole creature; the handler decides stomp vs kill.
	var sensor_rect := RectangleShape2D.new()
	sensor_rect.size = Vector2(w * 1.1, h * 1.05)
	_stomp_shape.shape = sensor_rect
	_stomp_shape.position = Vector2(0, 0.0 if flying else -h * 0.5)

	# Ledge probe (walkers only): looks down just ahead of the feet.
	_ledge.enabled = not flying
	_ledge.target_position = Vector2(0, 12)
	_position_ledge_probe()


func _physics_process(delta: float) -> void:
	if _dead:
		return

	# First-time how-to-kill hint: show when the player enters hint_range, hide when
	# they leave (edge-triggered). The controller ignores it once this enemy kind has
	# been killed, so the hint never comes back after the player learns it.
	var near := _player_in_radius(hint_range)
	if near != _player_near:
		_player_near = near
		if near:
			DialogueController.notify_enemy_nearby(stompable)
		else:
			DialogueController.notify_enemy_left(stompable)

	var attacking := _player_in_attack_zone()
	if attacking:
		# Turn to face the player while attacking.
		_face(_player.global_position.x - global_position.x)

	if flying:
		velocity = Vector2.ZERO if attacking else Vector2(move_speed * _dir, 0)
		move_and_slide()
		if not attacking and absf(global_position.x - _start_x) >= patrol_range:
			global_position.x = _start_x + patrol_range * signf(_dir)
			_face(-_dir)
	else:
		# Walker.
		velocity.y += gravity * delta
		velocity.x = 0.0 if attacking else move_speed * _dir
		move_and_slide()
		if not attacking:
			if is_on_wall():
				_face(-_dir)
			elif is_on_floor() and not _ledge.is_colliding():
				# Reached the edge of a platform — turn around.
				_face(-_dir)

	# Pick the looping animation (the one-shot "hit" reaction has priority).
	if not _reacting:
		_set_anim("attack" if attacking else "walk")


## Player hitbox in player.tscn: 7x15 rectangle at offset (-0.5, 1.5) from origin.
const PLAYER_HALF := Vector2(3.5, 7.5)
const PLAYER_HITBOX_OFFSET := Vector2(-0.5, 1.5)


## True when a living player is within `radius` px of the enemy centre. Used for the
## wider "how to kill" hint trigger (not the tight attack zone). Caches the player ref.
func _player_in_radius(radius: float) -> bool:
	if _player == null or not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group("player") as Node2D
		if _player == null:
			return false
	var center_y := global_position.y - (0.0 if flying else visual_height * 0.5)
	return _player.global_position.distance_to(Vector2(global_position.x, center_y)) <= radius

## True when the player's hitbox overlaps this enemy's attack zone (a box hugging the
## body, grown by attack_reach on every side). Caches the player reference.
func _player_in_attack_zone() -> bool:
	if _player == null or not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group("player") as Node2D
		if _player == null:
			return false
	# Enemy attack box centre, in world space.
	var center_y := global_position.y - (0.0 if flying else visual_height * 0.5)
	var zone_center := Vector2(global_position.x, center_y)
	var zone_half := Vector2(body_width * 0.5 + attack_reach, visual_height * 0.5 + attack_reach)
	# Player hitbox centre, in world space.
	var player_center := _player.global_position + PLAYER_HITBOX_OFFSET
	# AABB-vs-AABB overlap (Minkowski sum: add the half-extents).
	var combined := zone_half + PLAYER_HALF
	var delta := player_center - zone_center
	return absf(delta.x) <= combined.x and absf(delta.y) <= combined.y


func _set_anim(anim: String) -> void:
	if _sprite.sprite_frames.has_animation(anim) and _sprite.animation != anim:
		_sprite.play(anim)
	elif not _sprite.sprite_frames.has_animation(anim):
		_play_move_anim()


func _face(dir: float) -> void:
	_dir = signf(dir)
	if _dir == 0.0:
		_dir = -1.0
	# Sheets face right by default; flip when moving left.
	_sprite.flip_h = _dir < 0.0
	_position_ledge_probe()


func _position_ledge_probe() -> void:
	if _ledge:
		_ledge.position = Vector2(_dir * (body_width * 0.5 + 2.0), 0)


func _play_move_anim() -> void:
	if _sprite.sprite_frames.has_animation("walk"):
		_sprite.play("walk")
	elif _sprite.sprite_frames.has_animation("idle"):
		_sprite.play("idle")


func _on_player_touched(body: Node2D) -> void:
	if _dead or not (body is Player):
		return
	var player := body as Player
	if stompable and _is_player_stomping(player):
		_die_from_stomp(player)
	elif not GameState.invinsible:
		player.hit_by_enemy()


# True when the player is dropping onto the enemy from above (a stomp, not a hit).
func _is_player_stomping(player: Player) -> bool:
	var center_y := global_position.y - (0.0 if flying else visual_height * 0.5)
	return player.velocity.y > 0.0 and player.global_position.y < center_y - 2.0


# The attack swing connects on a specific frame: damage the player if still in range
# (but never override a stomp on a stompable enemy, and respect the Invincibility assist).
func _on_sprite_frame_changed() -> void:
	if _dead or _sprite.animation != "attack" or _sprite.frame != attack_hit_frame:
		return
	if not _player_in_attack_zone() or GameState.invinsible:
		return
	var player := _player as Player
	if player == null or (stompable and _is_player_stomping(player)):
		return
	player.hit_by_enemy()


func _die_from_stomp(player: Player) -> void:
	player.velocity.y = -stomp_bounce
	_flash_hit()
	_die()


# Called by the grapple hook (grapple.gd) when it strikes this enemy.
func take_grapple_hit() -> void:
	if _dead or grapple_hits <= 0:
		return
	_hp -= 1
	_flash_hit()                 # always give visual feedback, even on the killing blow
	if _hp <= 0:
		_die()
	else:
		_play_hit_anim()


func _flash_hit() -> void:
	# Restart cleanly so rapid hits always re-show the red flash.
	if _flash_tween and _flash_tween.is_valid():
		_flash_tween.kill()
	_sprite.modulate = Color(2.0, 0.7, 0.7)
	_flash_tween = create_tween()
	_flash_tween.tween_property(_sprite, "modulate", Color.WHITE, 0.18)


func _play_hit_anim() -> void:
	if _dead or not _sprite.sprite_frames.has_animation("hit"):
		return
	_reacting = true
	_sprite.play("hit")
	await _sprite.animation_finished
	if not _dead:
		_reacting = false


func _die() -> void:
	if _dead:
		return
	_dead = true
	# Clear the first-time how-to-kill hint for this enemy kind, for good.
	DialogueController.notify_enemy_killed(stompable)
	_stomp_zone.set_deferred("monitoring", false)
	set_deferred("collision_layer", 0)
	velocity = Vector2.ZERO
	if stomp_sound:
		SoundController.play(stomp_sound, -6, randf_range(0.95, 1.1))

	if _sprite.sprite_frames.has_animation("death"):
		_sprite.play("death")
		await _sprite.animation_finished
	else:
		await get_tree().create_timer(0.3).timeout
	queue_free()
