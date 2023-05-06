extends Node2D
# ==================================================
# メインシーン.
# ==================================================

# --------------------------------------------------
# const.
# --------------------------------------------------
const MAP_OFS_X = 0
const MAP_OFS_Y = 0

## 動作モード.
enum eMode {
	FREE, # フリー.
	BUY, # 購入.
	BUILD, # ビルド(配置).
	UPGRADE, # アップグレード.
}

# --------------------------------------------------
# preload.
# --------------------------------------------------
const ENEMY_OBJ = preload("res://src/Enemy.tscn")
const MENU_BUY_OBJ = preload("res://src/menu/MenuBuy.tscn")

# --------------------------------------------------
# on ready.
# --------------------------------------------------
@onready var _path2d = $EnemyLayer/Path2D
@onready var _tilemap = $TileMap
# CanvasLayer.
@onready var _tower_layer = $TowerLayer
@onready var _enemy_layer = $EnemyLayer
@onready var _shot_layer = $ShotLayer
@onready var _ui_layer = $UILayer
# UI.
@onready var _ui_cursor = $UILayer/Cursor
@onready var _ui_cursor_cross = $UILayer/Cursor/Cross
@onready var _ui_money = $UILayer/LabelMoney
@onready var _ui_wave = $UILayer/LabelWave
@onready var _ui_game_speed  = $UILayer/HSliderGameSpeed
@onready var _ui_game_speed_label = $UILayer/HSliderGameSpeed/Label

@onready var _ui_appear_enemy = $UILayer/DbgLayer/CheckAppearEnemy
@onready var _ui_debug_label = $UILayer/DbgLayer/DebugLabel

# --------------------------------------------------
# private var.
# --------------------------------------------------
var _mode = eMode.FREE
var _timer = 0.0
var _interval = 1.0
var _menu:MenuCommon

# --------------------------------------------------
# private function.
# --------------------------------------------------
## 開始.
func _ready() -> void:
	#DisplayServer.window_set_size(Vector2i(1152*2, 648*2))
	
	var layers = {
		"enemy": _enemy_layer,
		"shot": _shot_layer,
		"ui": _ui_layer,
	}
	Common.setup(layers)
	
	Map.setup(_tilemap)

## 更新.
func _process(delta: float) -> void:
	match _mode:
		eMode.FREE:
			_update_free(delta)
			# ゲームオブジェクトの更新.
			_update_objs(delta)
		eMode.BUY:
			_update_buy()
	# UIの更新.
	_update_ui()

## 更新 > FREE.
func _update_free(delta:float) -> void:
	# 敵の出現.
	_update_appear_enemy(delta)
	
	_ui_cursor.position = Map.get_mouse_pos(true)
	_ui_cursor.visible = true
	var mouse_grid_pos = Map.get_grid_mouse_pos()
	_ui_cursor_cross.visible = Map.cant_build_position(mouse_grid_pos)
	
	if Input.is_action_just_pressed("right-click"):
		_menu = MENU_BUY_OBJ.instantiate()
		_ui_layer.add_child(_menu)
		_mode = eMode.BUY

## 更新 > 購入.
func _update_buy() -> void:
	if _menu.closed():
		var result = _menu.get_result()
		_menu.queue_free()
		_mode = eMode.FREE

## 更新 > ゲームオブジェクト.
func _update_objs(delta:float) -> void:
	# タワー更新.
	for tower in _tower_layer.get_children():
		tower.update_manual(delta)
	# 敵の更新.
	_update_enemy(delta)
	# ショットの更新.
	for shot in _shot_layer.get_children():
		shot.update_manual(delta)

## 更新 > 敵の移動.
func _update_enemy(delta:float) -> void:
	var enemies = Common.get_enemies()
	for enemy in enemies:
		enemy.update_manual(delta)

## 更新 > 敵の出現.
func _update_appear_enemy(delta:float) -> void:
	if _ui_appear_enemy.button_pressed == false:
		return
		
	_timer += delta	
	if _timer >= _interval:
		_timer = 0.0
		# 敵を生成.
		var enemy = ENEMY_OBJ.instantiate()
		enemy.setup(_path2d)

## 更新 > UI.
func _update_ui() -> void:
	# 所持金の更新.
	_ui_money.text = "所持金: $%d"%Common.money
	
	# ウェーブ数の更新.
	
	# ゲーム速度の更新.
	Common.game_speed = _ui_game_speed.value
	_ui_game_speed_label.text = "SPEED x%3.1f"%Common.game_speed

	# デバッグ用.
	_ui_debug_label.text = "Enemy:%d"%Common.get_enemies().size()
