extends Node

# ==================================================
# 敵の生成管理..
# ==================================================
class_name EnemySpawnMgr

# --------------------------------------------------
# const.
# --------------------------------------------------
enum eState {
	STANDBY,
	MAIN,
	END_WAIT,
}

# --------------------------------------------------
# preload.
# --------------------------------------------------
const ENEMY_OBJ = preload("res://src/enemy/Enemy.tscn")

# --------------------------------------------------
# private vars.
# --------------------------------------------------
var _path2d:Path2D
var _state = eState.STANDBY
var _spawn_timer = 0.0
var _spawn_number = 0 # 敵を生成した数.

# --------------------------------------------------
# public functions.
# --------------------------------------------------
## 開始.
func start() -> void:
	# Waveを進める.
	Common.next_wave()
	
	_state = eState.MAIN
	_spawn_timer = 0.0
	_spawn_number = 0
	
## Waveの敵が出尽くしたかどうか.
func is_wait() -> bool:
	return _state == eState.END_WAIT

## 更新.
func update_manual(delta:float) -> void:
	match _state:
		eState.STANDBY:
			pass # 何もしない.
		eState.MAIN:
			_update_main(delta)
			_spawn_timer

func get_spawn_number() -> int:
	return _spawn_number
func get_spawn_number_max() ->int:
	return Game.enemy_spawn_number(Common.wave)

# --------------------------------------------------
# private functions.
# --------------------------------------------------
## コンストラクタ.
func _init(path2d:Path2D):
	_path2d = path2d

## 更新 > メイン.
func _update_main(delta:float) -> void:
	# 生成タイマーを加算.
	_spawn_timer += delta
	var interval = Game.enemy_interval(Common.wave)
	if _spawn_timer >= interval:
		_spawn_timer = 0.0
		# 敵を生成.
		var enemy = ENEMY_OBJ.instantiate()
		enemy.setup(_path2d)
		_spawn_number += 1
		if _spawn_number >= get_spawn_number_max():
			# 次のWaveに進む.
			_state = eState.END_WAIT
