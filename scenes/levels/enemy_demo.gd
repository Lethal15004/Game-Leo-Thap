extends Node2D

# Small test arena for the four enemy types.
# Acts as the player's "owner": player._on_hit() calls owner.respawn() when the
# player touches an enemy's hazard body, so respawn() must live here.

func _ready() -> void:
	ScreenFade.set_circle(1, 0)


func respawn() -> void:
	ScreenFade.set_circle(0, 0.4)
	await ScreenFade.done
	get_tree().reload_current_scene()


func _unhandled_key_input(event: InputEvent) -> void:
	var key := event as InputEventKey
	if key.is_pressed() and key.keycode == KEY_R:
		get_tree().reload_current_scene()
