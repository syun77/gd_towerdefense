extends Node2D
# ==================================================
# メインシーン.
# ==================================================

# --------------------------------------------------
# const.
# --------------------------------------------------
const FADE_ALPHA = 1.0
const FADE_TIMER = 0.2
const HELP_OFS_Y = -48.0
const TIMER_SHAKE = 0.5
const TIME_OUT = 5.0
const TIMER_VIGNETTE = 0.5

## 状態.
enum eState {
	STANDBY,
	MAIN,
	GAMEOVER,
}

## 動作モード.
enum eMode {
	FREE, # フリー.
	BUY, # 購入.
	BUILD, # ビルド(配置).
	UPGRADE, # アップグレード.
}

enum eHelp {
	NONE,
	BUY,
	UPGRADE,
	BUY_MENU,
	UPGRADE_MENU,
	BUILD,
	NEXT_WAVE,
}

# --------------------------------------------------
# preload.
# --------------------------------------------------
const TOWER_OBJ = preload("res://src/Tower.tscn")
const MENU_BUY_OBJ = preload("res://src/menu/MenuBuy.tscn")
const MENU_UPGRADE_OBJ = preload("res://src/menu/MenuUpgrade.tscn")
const WAVE_START_OBJ = preload("res://src/WaveStart.tscn")

# --------------------------------------------------
# on ready.
# --------------------------------------------------
@onready var _path2d = $EnemyLayer/Path2D
@onready var _tilemap = $TileMap
# CanvasLayer.
@onready var _tower_layer = $TowerLayer
@onready var _enemy_layer = $EnemyLayer
@onready var _shot_layer = $ShotLayer
@onready var _particle_layer = $ParticleLayer
@onready var _ui_layer = $UILayer
# UI.
@onready var _ui_vignette = $UILayer/VignetteFilter
@onready var _ui_pause_bg = $UILayer/PauseBG
@onready var _ui_next_wave = $UILayer/ButtonNext
@onready var _ui_cursor = $UILayer/Cursor
@onready var _ui_cursor_cross = $UILayer/Cursor/Cross
@onready var _ui_cursor_tower = $UILayer/Cursor/Tower
@onready var _ui_money = $UILayer/LabelMoney
@onready var _ui_wave = $UILayer/LabelWave
@onready var _ui_wave_max = $UILayer/LabelWaveBest
@onready var _ui_enemy = $UILayer/LabelEnemy
@onready var _ui_game_speed  = $UILayer/HSliderGameSpeed
@onready var _ui_game_speed_label = $UILayer/HSliderGameSpeed/Label
@onready var _ui_help = $UILayer/Help
@onready var _ui_help_label = $UILayer/Help/Label
@onready var _ui_health_label = $UILayer/Health/Label
@onready var _ui_caption = $UILayer/LabelCaption

@onready var _ui_appear_enemy = $UILayer/DbgLayer/CheckAppearEnemy
# カメラ
@onready var _camera = $Camera2D

# --------------------------------------------------
# private var.
# --------------------------------------------------
var _state = eState.STANDBY
var _mode = eMode.FREE
var _menu:MenuCommon
var _spawn_mgr:EnemySpawnMgr
var _buy_type = Game.eTower.NORMAL
var _buy_cost = 0
var _start_next_wave = false
var _help = eHelp.NONE
var _selected_tower:Tower
var _timer_shake = 0.0
var _cnt = 0
var _timeout = 0.0
var _timer_vignette = 0.0

# --------------------------------------------------
# private function.
# --------------------------------------------------
## 開始.
func _ready() -> void:
	#DisplayServer.window_set_size(Vector2i(1152*2, 648*2))
	
	Common.init()
	
	_set_vignette(0.0)
	_ui_pause_bg.modulate.a = 0.0
	_ui_wave.visible = false
	_ui_wave_max.visible = false
	_ui_enemy.visible = false
	_ui_next_wave.visible = true
	_ui_caption.visible = false
	
	# レイヤーを登録する.
	var layers = {
		"tower": _tower_layer,
		"enemy": _enemy_layer,
		"shot": _shot_layer,
		"particle": _particle_layer,
		"ui": _ui_layer,
	}
	Common.setup(layers)
	
	# タイルマップを渡す.
	Map.setup(_tilemap)
	
	# 敵管理を生成.
	_spawn_mgr = EnemySpawnMgr.new(_path2d)
	
	_change_help(eHelp.BUY)
	_timeout = TIME_OUT

## 更新.
func _physics_process(delta: float) -> void:
	_cnt += 1
	
	# ゲーム速度変更.
	var delta2 = delta * Common.game_speed
	match _state:
		eState.STANDBY:
			_update_standby(delta)
		eState.MAIN:
			_update_main(delta2)
		eState.GAMEOVER:
			_update_gameover(delta)
	
	if _state != eState.GAMEOVER:
		match _mode:
			eMode.FREE:
				_update_free(delta2)
				# ゲームオブジェクトの更新.
				_update_objs(delta2)
			eMode.BUY:
				_update_buy()
			eMode.BUILD:
				_update_build()	
			eMode.UPGRADE:
				_update_upgrade()

	# カメラの更新.
	_update_camera(delta)
	
	# Vignetteの更新.
	_update_vignette(delta)

	# UIの更新.
	_update_ui(delta)

## 更新 > 待機中.
func _update_standby(delta:float):
	if _is_count_down():
		# 自由操作 and 時間経過.
		_timeout -= delta
	if _start_next_wave or _timeout <= 0.0:
		_ui_next_wave.visible = false
		_start_next_wave = false
		
		# Wave開始.
		var caption = WAVE_START_OBJ.instantiate()
		_ui_layer.add_child(caption)
		_spawn_mgr.start()
		# 各種UIを表示.
		_ui_wave.visible = true
		_ui_enemy.visible = true
		_state = eState.MAIN

func _is_count_down() -> bool:
	if _mode != eMode.FREE:
		return false # FREE操作でなければタイムアウトしない.
	if Common.wave < 1: # 最初のWave開始前.
		if _tower_layer.get_child_count() == 0:
			return false # 1つも建設していなければタイムアウトしない.
	
	return true

## 更新 > メイン.
func _update_main(delta:float):
	if Common.is_dead():
		# ゲームオーバー処理
		_state = eState.GAMEOVER
		return
	
	if _spawn_mgr.is_wait() == false:
		return # Wave続行中.
	var cnt = Common.get_enemies().size()
	if cnt > 0:
		return # 敵がまだ残っている.
	
	# Wave終了.
	_ui_next_wave.visible = true
	_timeout = TIME_OUT # タイムアウト時間を設定.
	_state = eState.STANDBY
	
func _update_gameover(_delta:float) -> void:
	_ui_caption.visible = true
	if Input.is_action_just_pressed("click"):
		# リスタート.
		get_tree().change_scene_to_file("res://Main.tscn")

## 更新 > FREE.
func _update_free(delta:float) -> void:
	# 敵の出現.
	_update_appear_enemy(delta)
	
	# カーソルの更新.
	_ui_cursor.position = Map.get_mouse_pos(true)
	_ui_cursor.visible = true
	
	if Input.is_action_just_pressed("right-click"):
		if is_instance_valid(_selected_tower):
			# アップグレードメニューを開く.
			_open_memu_upgrade(_selected_tower)
		else:
			# 購入メニューを開く.
			_open_menu_buy()

## アップグレードメニューを開く.
func _open_memu_upgrade(tower:Tower) -> void:
	_menu = MENU_UPGRADE_OBJ.instantiate()
	_menu.setup(tower)
	_ui_layer.add_child(_menu)
	_mode = eMode.UPGRADE

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
		var tbl = {
			MenuCommon.eResult.BUY_NORMAL: Game.eTower.NORMAL,
			MenuCommon.eResult.BUY_LASER: Game.eTower.LASER,
			MenuCommon.eResult.BUY_HORMING: Game.eTower.HORMING,
		}
		if result in tbl:
			# ビルドへ.
			_buy_type = tbl[result]
			var path = Game.tower_texture_path(_buy_type)
			# カーソル用のタワーを読み込む.
			_ui_cursor_tower.texture = load(path)
			_mode = eMode.BUILD
		else:
			# キャンセルした.
			_mode = eMode.FREE
			
## 更新 > アップグレード.
func _update_upgrade() -> void:
	if _menu.closed():
		_menu.queue_free()
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
	var num = 0
	for tower in Common.get_layer("tower").get_children():
		var t:Tower = tower
		if t.get_type() == _buy_type:
			num += 1 # 一致する種別のみ.
	
	_buy_cost = Game.tower_cost(num, _buy_type)
	if Common.money < _buy_cost or Input.is_action_just_pressed("right-click"):
		# お金足りない or キャンセル.
		_cancel_build()
	elif Input.is_action_just_pressed("click"):
		if cant_build:
			print("ここには建設できない")
		else:
			# ビルド実行.
			_exec_build(_buy_cost)

## ビルド実行.
func _exec_build(cost:int) -> void:
	# ビルドする.
	var tower = TOWER_OBJ.instantiate()
	_tower_layer.add_child(tower)
	tower.setup(_ui_cursor.position, _buy_type)
	# お金を減らす.
	Common.spend_money(cost)

## ビルドをキャンセル.
func _cancel_build() -> void:
	_ui_cursor_cross.visible = false
	_ui_cursor_tower.visible = false
	_mode = eMode.FREE
	
func _change_help(help:eHelp) -> void:
	if _help == help:
		return # 同じなので更新不要.
	
	var tbl = {
		eHelp.NONE: "",
		eHelp.BUY: "右クリックでタワーを購入",
		eHelp.UPGRADE: "右クリックでタワーをアップグレード",
		eHelp.BUY_MENU: "購入するタワーを選択",
		eHelp.UPGRADE_MENU: "アップグレードする項目を選択",
		eHelp.BUILD: "左クリックでタワーを配置",
		eHelp.NEXT_WAVE: "「開始」ボタンでWAVEを開始",
	}
	_ui_help.position.y = HELP_OFS_Y
	_ui_help.visible = true
	_ui_help_label.text = tbl[help]
	
	_help = help
	
	if help == eHelp.NONE:
		_ui_help.visible = false

func _update_help(_delta:float) -> void:
	_ui_help.position.y *= 0.9

## 更新 > ゲームオブジェクト.
func _update_objs(delta:float) -> void:
	
	_selected_tower = null
	var tower_cnt = _tower_layer.get_child_count()
	# タワー更新.
	for tower in _tower_layer.get_children():
		tower.update_manual(delta)
		# 選択状態も更新しておく.
		var mouse = Map.get_grid_mouse_pos()
		var pos:Vector2i = Map.world_to_grid(tower.position)
		tower.selected = (mouse == pos)
		if tower.selected:
			_selected_tower = tower
	
	if is_instance_valid(_selected_tower):
		_change_help(eHelp.UPGRADE)
	elif Common.wave == 0:
		if tower_cnt > 0:
			_change_help(eHelp.NEXT_WAVE)
	else:
		_change_help(eHelp.NONE)
	
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

## 更新 > カメラ.
func _update_camera(delta:float) -> void:
	if Common.is_damage:
		Common.is_damage = false
		# 揺れ開始.
		_timer_shake = TIMER_SHAKE
		_timer_vignette = TIMER_VIGNETTE
	
	_camera.offset = Vector2.ZERO
	if _timer_shake <= 0.0:
		return
	_timer_shake -= delta
	var rate = _timer_shake / TIMER_SHAKE
	var x = 8 * rate
	if _cnt%4 < 2:
		x *= -1
	_camera.offset.x = x
	_camera.offset.y = 4 * rate * randf_range(-1, 1)	

func _update_vignette(delta:float) -> void:
	if _timer_vignette <= 0.0:
		_set_vignette(0)
		return
	_timer_vignette -= delta
	var rate = _timer_vignette / TIMER_VIGNETTE
	var intensity = 0.4 * (1.0 - Common.healt_ratio())
	_set_vignette(rate, intensity)

## Vignetteの透過値を設定する.
func _set_vignette(alpha:float, intensity:float=0.4) -> void:
	var mat:ShaderMaterial = _ui_vignette.material
	mat.set_shader_parameter("vignette_opacity", alpha)
	mat.set_shader_parameter("vignette_intensity", intensity)

## 更新 > UI.
func _update_ui(delta:float) -> void:
	_ui_pause_bg.visible = true
	if _mode == eMode.FREE:
		_ui_pause_bg.modulate.a = max(0, _ui_pause_bg.modulate.a - FADE_ALPHA * delta / FADE_TIMER)
	else:
		_ui_pause_bg.modulate.a = min(FADE_ALPHA, _ui_pause_bg.modulate.a + FADE_ALPHA * delta / FADE_TIMER)
	
	# ヘルプの更新.
	_update_help(delta)
	
	# 所持金の更新.
	_ui_money.text = "所持金:$%d"%Common.money
	if _mode == eMode.BUILD:
		_ui_money.text += " (-$%d)"%_buy_cost
	
	# ウェーブ数の更新.
	_ui_wave.text = "Wave:%d"%Common.wave
	
	# 最大到達ウェーブ数の更新.
	if Common.wave_best > Common.INIT_WAVE:
		_ui_wave_max.visible = true
		_ui_wave_max.text = "最大Wave:%d"%Common.wave_best
	
	# 敵出現数.
	_ui_enemy.text = "敵:(%d/%d)"%[_spawn_mgr.get_spawn_number(), _spawn_mgr.get_spawn_number_max()]
	
	# ライフ.
	_ui_health_label.text = "x%d"%Common.health
	
	# ゲーム速度の更新.
	Common.game_speed = _ui_game_speed.value
	_ui_game_speed_label.text = "SPEED x%3.1f"%Common.game_speed


# --------------------------------------------------
# signal functions.
# --------------------------------------------------
func _on_button_next_pressed() -> void:
	if _mode == eMode.FREE:
		# 次のWave開始.
		_start_next_wave = true
