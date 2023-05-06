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
@onready var _path2d = $EnemyLayer/Path2D
@onready var _tilemap = $TileMap
# CanvasLayer.
@onready var _enemy_layer = $EnemyLayer
@onready var _shot_layer = $ShotLayer
@onready var _ui_layer = $UILayer
# UI.
@onready var _ui_cursor = $UILayer/Cursor
@onready var _ui_cursor_cross = $UILayer/Cursor/Cross

@onready var _ui_game_speed  = $UILayer/HSliderGameSpeed
@onready var _ui_game_speed_label = $UILayer/HSliderGameSpeed/Label

@onready var _ui_debug_label = $UILayer/DebugLabel

# --------------------------------------------------
# private var.
# --------------------------------------------------

# --------------------------------------------------
# private function.
# --------------------------------------------------
## 開始.
func _ready() -> void:
	DisplayServer.window_set_size(Vector2i(1152*2, 648*2))
	
	var layers = {
		"enemy": _enemy_layer,
		"shot": _shot_layer,
		"ui": _ui_layer,
	}
	Common.setup(layers)
	
	Map.setup(_tilemap)

## 更新.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("click"):
		# 敵を生成.
		var enemy = ENEMY_OBJ.instantiate()
		enemy.setup(_path2d)
	
	_ui_cursor.position = Map.get_mouse_pos(true)
	_ui_cursor.visible = true
	var mouse_grid_pos = Map.get_grid_mouse_pos()
	_ui_cursor_cross.visible = Map.cant_build_position(mouse_grid_pos)
	
	# UIの更新.
	_update_ui()

## 更新 > UI.
func _update_ui() -> void:
	# ゲーム速度の更新.
	Common.game_speed = _ui_game_speed.value
	_ui_game_speed_label.text = "SPEED x%3.1f"%Common.game_speed

	_ui_debug_label.text = "Enemy:%d"%Common.get_enemies().size()
