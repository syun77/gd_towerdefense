extends Area2D
# ==================================================
# 敵シーン.
# ==================================================
class_name Enemy

# --------------------------------------------------
# const.
# --------------------------------------------------
# 移動速度。64px/s
const MOVE_SPEED = 64.0

# --------------------------------------------------
# onready.
# --------------------------------------------------
@onready var _spr = $AnimatedSprite2D
@onready var _health_bar = $HeathBar

# --------------------------------------------------
# private var.
# --------------------------------------------------
# PathFollow2Dが親となる.
var _parent:PathFollow2D = null

var _hp:int = 0
var _max_hp:int = 0
var _money:int = 3 # 所持金.

var _prev_pos = Vector2()

# --------------------------------------------------
# public function.
# --------------------------------------------------
## セットアップ.
func setup(path2d:Path2D) -> void:
	_parent = PathFollow2D.new()
	_parent.loop = false # ループしない.
	_parent.rotates = false # 回転しない.
	_parent.add_child(self) # 自身を登録する.
	
	# Path2Dに登録する.
	path2d.add_child(_parent)
	
	# アニメーションを再生.
	$AnimatedSprite2D.play("default")
	
	set_hp(3)
	
## HPを設定.
func set_hp(v:int) -> void:
	_hp = v
	_max_hp = v

## HPの割合を取得する.
func get_hpratio() -> float:
	return 1.0 * _hp / _max_hp

## ダメージ処理.
func damage(shot:Shot) -> void:
	var power = shot.get_power()
	_hp -= power
	if _hp <= 0:
		# 消滅.
		vanish()
		# お金ゲット!
		Common.add_money(_money)

## 消滅.
func vanish() -> void:
	queue_free()
	
## 手動更新 (_process()は使わない).
func update_manual(delta:float) -> void:
	# 可変.
	delta *= Common.game_speed
	
	# 移動処理
	_parent.progress += MOVE_SPEED * delta
	
	# 回転処理.
	_update_rotate()
	
	# 終了チェック.
	if _parent.progress_ratio >= 1.0:
		# 親を消すことで自身も消える.
		_parent.queue_free()
		return

	# HPバーの更新.
	_update_health_bar()
	

# --------------------------------------------------
# private function.
# --------------------------------------------------
## 開始.
func _ready() -> void:
	# 体力ゲージは消しておく.
	_health_bar.visible = false

## 回転処理.
func _update_rotate():
	var pos = _parent.position
	var d = pos - _prev_pos
	_spr.rotation = d.angle()
	_prev_pos = pos

## HPバーの更新.
func _update_health_bar() -> void:
	var rate = get_hpratio()
	if rate < 1.0:
		_health_bar.visible = true
		_health_bar.value = 100 * rate
	
# --------------------------------------------------
# signal function.
# --------------------------------------------------
## 衝突.
func _on_area_entered(area: Area2D) -> void:
	if area is Shot:
		# ダメージ処理.
		damage(area)
		# 弾を消しておく.
		area.vanish()
