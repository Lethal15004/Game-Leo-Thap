# Probe tạm (sẽ xoá): dump tilemap ra ASCII để phân tích cấu trúc map.
# '#'=solid, '^'=hazard(gai), '='=oneway, '.'=tile trang trí, ' '=trống.
# Chạy: Godot --headless --path . --script res://tools/dump_map.gd
extends SceneTree

func _initialize() -> void:
	var packed: PackedScene = load("res://scenes/main.tscn")
	# KHÔNG add vào tree: _ready không chạy, chỉ đọc dữ liệu tĩnh.
	var scene := packed.instantiate()
	var tilemap: TileMap = scene.get_node("Tilemap")
	var rect := tilemap.get_used_rect()

	var lines := PackedStringArray()
	lines.append("# Map dump: cols x=%d..%d, rows y=%d..%d (1 tile=16px)" % [
		rect.position.x, rect.end.x - 1, rect.position.y, rect.end.y - 1])

	# Gom object theo hàng tile để in kèm
	var objs := {}
	for child in scene.get_children():
		if child is Node2D and child.name not in ["Tilemap", "TutorialPrompts", "Enemies"]:
			var ty := int(floor((child as Node2D).position.y / 16.0))
			if not objs.has(ty):
				objs[ty] = []
			objs[ty].append("%s(%d,%d)" % [child.name, (child as Node2D).position.x, (child as Node2D).position.y])
	var enemies := scene.get_node_or_null("Enemies")
	if enemies:
		for e in enemies.get_children():
			var ty := int(floor((e as Node2D).position.y / 16.0))
			if not objs.has(ty):
				objs[ty] = []
			objs[ty].append("E:%s(%d,%d)" % [e.name, (e as Node2D).position.x, (e as Node2D).position.y])

	for y in range(rect.position.y, rect.end.y):
		var row := ""
		for x in range(rect.position.x, rect.end.x):
			var src := tilemap.get_cell_source_id(0, Vector2i(x, y))
			if src == -1:
				row += " "
				continue
			var td := tilemap.get_cell_tile_data(0, Vector2i(x, y))
			if td == null:
				row += "?"
			elif td.get_collision_polygons_count(2) > 0:
				row += "^"
			elif td.get_collision_polygons_count(0) > 0:
				row += "#"
			elif td.get_collision_polygons_count(1) > 0:
				row += "="
			else:
				row += "."
		var suffix := ""
		if objs.has(y):
			suffix = "  | " + ", ".join(objs[y])
		lines.append("%5d %s%s" % [y, row, suffix])

	var f := FileAccess.open("res://docs/map_dump.txt", FileAccess.WRITE)
	f.store_string("\n".join(lines))
	f.close()
	print("WROTE docs/map_dump.txt rows=", rect.size.y)
	scene.free()
	quit()
