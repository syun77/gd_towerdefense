extends Node2D
# ==================================================
# メインシーン.
# ==================================================

# --------------------------------------------------
# const.
# --------------------------------------------------
const MAP_OFS_X = 0
const MAP_OFS_Y = 0

# --------------------------------------------------
# preload.
# --------------------------------------------------
const ENEMY_OBJ = preload("res://src/Enemy.tscn")

# --------------------------------------------------
# on ready.
# --------------------------------------------------
@onready var _path2d = $Path2D
@onready var _tilemap = $TileMap
# UI.
@onready var _ui_cursor = $UILayer/Cursor
@onready var _ui_game_speed  = $UILayer/HSliderGameSpeed
@onready var _ui_game_speed_label = $UILayer/HSliderGameSpeed/Label

# --------------------------------------------------
# private var.
# --------------------------------------------------

# --------------------------------------------------
# private function.
# --------------------------------------------------
## 開始.
func _ready() -> void:
	#DisplayServer.window_set_size(Vector2i(1152*2, 648*2))
	pass

## 更新.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("click"):
		# 敵を生成.
		var enemy = ENEMY_OBJ.instantiate()
		enemy.setup(_path2d)
	
	_ui_cursor.position = get_cursor_pos()
	_ui_cursor.visible = true
	
	# UIの更新.
	_update_ui()

## 更新 > UI.
func _update_ui() -> void:
	# ゲーム速度の更新.
	Common.game_speed = _ui_game_speed.value
	_ui_game_speed_label.text = "SPEED x%3.1f"%Common.game_speed

## タイルサイズを取得する.
func get_tile_size() -> int:
	# 正方形なので xの値 でOK.
	return _tilemap.tile_set.tile_size.x

## ワールド座標をグリッド座標に変換する.
func world_to_grid(world:Vector2) -> Vector2:
	var grid = Vector2()
	grid.x = world_to_grid_x(world.x)
	grid.y = world_to_grid_y(world.y)
	return grid
func world_to_grid_x(wx:float) -> float:
	var size = get_tile_size()
	return  (wx-MAP_OFS_X) / size
func world_to_grid_y(wy:float) -> float:
	var size = get_tile_size()
	return (wy-MAP_OFS_Y) / size

## グリッド座標をワールド座標に変換する.
func grid_to_world(grid:Vector2) -> Vector2:
	var world = Vector2()
	world.x = grid_to_world_x(grid.x)
	world.y = grid_to_world_y(grid.y)
	return world
func grid_to_world_x(gx:float) -> float:
	var size = get_tile_size()
	return MAP_OFS_X + (gx * size)
func grid_to_world_y(gy:float) -> float:
	var size = get_tile_size()
	return MAP_OFS_Y + (gy * size)

## マウスカーソルの位置をグリッド座標で取得する.
func get_grid_pos() -> Vector2i:
	var mouse = get_viewport().get_mouse_position()
	return world_to_grid(mouse)
func get_cursor_pos(snapped:bool=false) -> Vector2:
	# いったん整数
	var pos = get_grid_pos()
	return grid_to_world(pos)
