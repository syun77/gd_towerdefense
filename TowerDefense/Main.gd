extends Node2D
# ==================================================
# メインシーン.
# ==================================================

# --------------------------------------------------
# const.
# --------------------------------------------------
const FADE_ALPHA = 1.0
const FADE_TIMER = 0.2

## 状態.
enum eState {
	STANDBY,
	MAIN,
}

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
const TOWER_OBJ = preload("res://src/Tower.tscn")
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
@onready var _ui_pause_bg = $UILayer/PauseBG
@onready var _ui_cursor = $UILayer/Cursor
@onready var _ui_cursor_cross = $UILayer/Cursor/Cross
@onready var _ui_cursor_tower = $UILayer/Cursor/Tower
@onready var _ui_money = $UILayer/LabelMoney
@onready var _ui_wave = $UILayer/LabelWave
@onready var _ui_enemy = $UILayer/LabelEnemy
@onready var _ui_game_speed  = $UILayer/HSliderGameSpeed
@onready var _ui_game_speed_label = $UILayer/HSliderGameSpeed/Label

@onready var _ui_appear_enemy = $UILayer/DbgLayer/CheckAppearEnemy

# --------------------------------------------------
# private var.
# --------------------------------------------------
var _state = eState.STANDBY
var _mode = eMode.FREE
var _menu:MenuCommon
var _spawn_mgr:EnemySpawnMgr
var _buy_type = Tower.eType.NORMAL

# --------------------------------------------------
# private function.
# --------------------------------------------------
## 開始.
func _ready() -> void:
	DisplayServer.window_set_size(Vector2i(1152*2, 648*2))
	
	_ui_pause_bg.modulate.a = 0.0
	_ui_wave.visible = false
	_ui_enemy.visible = false
	
	# レイヤーを登録する.
	var layers = {
		"tower": _tower_layer,
		"enemy": _enemy_layer,
		"shot": _shot_layer,
		"ui": _ui_layer,
	}
	Common.setup(layers)
	
	# タイルマップを渡す.
	Map.setup(_tilemap)
	
	# 敵管理を生成.
	_spawn_mgr = EnemySpawnMgr.new(_path2d)

## 更新.
func _process(delta: float) -> void:
	match _state:
		eState.STANDBY:
			_update_standby()
		eState.MAIN:
			_update_main(delta)
	
	match _mode:
		eMode.FREE:
			_update_free(delta)
			# ゲームオブジェクトの更新.
			_update_objs(delta)
		eMode.BUY:
			_update_buy()
		eMode.BUILD:
			_update_build()	

	# UIの更新.
	_update_ui(delta)

## 更新 > 待機中.
func _update_standby():
	if Input.is_action_just_pressed("click"):
		# Wave開始.
		_spawn_mgr.start()
		# 各種UIを表示.
		_ui_wave.visible = true
		_ui_enemy.visible = true
		_state = eState.MAIN

## 更新 > メイン.
func _update_main(delta:float):
	if _spawn_mgr.is_wait() == false:
		return # Wave続行中.
	var cnt = Common.get_enemies().size()
	if cnt > 0:
		return # 敵がまだ残っている.
	
	# Wave終了.
	_state = eState.STANDBY

## 更新 > FREE.
func _update_free(delta:float) -> void:
	# 敵の出現.
	_update_appear_enemy(delta)
	
	# カーソルの更新.
	_ui_cursor.position = Map.get_mouse_pos(true)
	_ui_cursor.visible = true
	
	if Input.is_action_just_pressed("right-click"):
		# 購入メニューを開く.
		_open_menu_buy()

## 購入メニューを開く.
func _open_menu_buy() -> void:
	_menu = MENU_BUY_OBJ.instantiate()
	_ui_layer.add_child(_menu)
	_mode = eMode.BUY

## 更新 > 購入.
func _update_buy() -> void:
	if _menu.closed():
		var result = _menu.get_result()
		_menu.queue_free()
		var tbl = [
			MenuCommon.eResult.BUY_NORMAL, Tower.eType.NORMAL,
			MenuCommon.eResult.BUY_LASER, Tower.eType.LASER,
			MenuCommon.eResult.BUY_HORMING, Tower.eType.HORMING,
		]
		if result in tbl:
			# ビルドへ.
			_buy_type = tbl[result]
			_mode = eMode.BUILD
		else:
			# キャンセルした.
			_mode = eMode.FREE

## 更新 > ビルド(配置).
func _update_build() -> void:
	# カーソルの更新.
	_ui_cursor.position = Map.get_mouse_pos(true)
	_ui_cursor.visible = true
	# 配置できるかどうか.
	var mouse_grid_pos = Map.get_grid_mouse_pos()
	## 地形をチェック.
	var cant_build = Map.cant_build_position(mouse_grid_pos)
	## タワーのチェックも必要.
	for tower in _tower_layer.get_children():
		var grid:Vector2i = Map.world_to_grid(tower.position)
		if grid == mouse_grid_pos:
			# 置けない.
			cant_build = true
			break
	_ui_cursor_cross.visible = cant_build
	_ui_cursor_tower.visible = (cant_build == false)
	if cant_build == false:
		_ui_cursor_tower.visible = true
	
	# タワーの生存数.
	var num = _tower_layer.get_child_count()
	var cost = Game.tower_cost(num)
	if Common.money < cost or Input.is_action_just_pressed("right-click"):
		# お金足りない or キャンセル.
		_cancel_build()
	elif Input.is_action_just_pressed("click"):
		if cant_build:
			print("ここには建設できない")
		else:
			# ビルド実行.
			_exec_build(cost)

## ビルド実行.
func _exec_build(cost:int) -> void:
	# ビルドする.
	var tower = TOWER_OBJ.instantiate()
	_tower_layer.add_child(tower)
	tower.setup(_ui_cursor.position)
	# お金を減らす.
	Common.spend_money(cost)

## ビルドをキャンセル.
func _cancel_build() -> void:
	_ui_cursor_cross.visible = false
	_ui_cursor_tower.visible = false
	_mode = eMode.FREE
	

## 更新 > ゲームオブジェクト.
func _update_objs(delta:float) -> void:
	# タワー更新.
	for tower in _tower_layer.get_children():
		tower.update_manual(delta)
		# 選択状態も更新しておく.
		var mouse = Map.get_grid_mouse_pos()
		var pos:Vector2i = Map.world_to_grid(tower.position)
		tower.selected = (mouse == pos)
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
	
	_spawn_mgr.update_manual(delta)


## 更新 > UI.
func _update_ui(delta:float) -> void:
	_ui_pause_bg.visible = true
	if _mode == eMode.FREE:
		_ui_pause_bg.modulate.a = max(0, _ui_pause_bg.modulate.a - FADE_ALPHA * delta / FADE_TIMER)
	else:
		_ui_pause_bg.modulate.a = min(FADE_ALPHA, _ui_pause_bg.modulate.a + FADE_ALPHA * delta / FADE_TIMER)
	
	# 所持金の更新.
	_ui_money.text = "所持金: $%d"%Common.money
	
	# ウェーブ数の更新.
	_ui_wave.text = "Wave:%d"%Common.wave
	
	# 敵出現数.
	_ui_enemy.text = "敵:(%d/%d)"%[_spawn_mgr.get_spawn_number(), _spawn_mgr.get_spawn_number_max()]
	
	# ゲーム速度の更新.
	Common.game_speed = _ui_game_speed.value
	_ui_game_speed_label.text = "SPEED x%3.1f"%Common.game_speed

