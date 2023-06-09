extends Area2D
# ==================================================
# ショットシーン.
# ==================================================
class_name Shot

# --------------------------------------------------
# const.
# --------------------------------------------------

# --------------------------------------------------
# private var.
# --------------------------------------------------
var _velocity = Vector2()
var _deg = 0.0 # 角度.
var _speed = 1.0 # 速さ.
var _power = 1 # 攻撃力.
var _timer = 0.0
var _tower = Game.eTower

# --------------------------------------------------
# public function.
# --------------------------------------------------
## セットアップ.
func setup(pos:Vector2, deg:float, speed:float, power:int, tower:Game.eTower) -> void:
	position = pos
	_power = power
	set_velocity(deg, speed)
	_tower = tower

## 角度と速さから速度を設定する.
func set_velocity(deg:float, speed:float) -> void:
	var rad = deg_to_rad(deg)
	_velocity.x = speed * cos(rad)
	_velocity.y = speed * -sin(rad)
	
	_deg = deg
	_speed = speed

## 角度を取得する.
func get_degrees() -> float:
	return _deg
	
## 発射したタワーの種類.
func get_tower_type() -> Game.eTower:
	return _tower
	
## 消滅.
func vansih() -> void:
	queue_free()

## 攻撃力.
func get_power() -> int:
	return _power

## 消滅する.
func vanish() -> void:
	queue_free()
	
## 手動更新.
func update_manual(delta:float) -> void:
	position += _velocity * delta
	
	if Common.is_outside(self, 16):
		# 画面外に出た.
		vanish()

# --------------------------------------------------
# private function.
# --------------------------------------------------
## 開始.
func _ready() -> void:
	pass
