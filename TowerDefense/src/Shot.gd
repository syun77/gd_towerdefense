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
var _power = 1 # 攻撃力.

# --------------------------------------------------
# public function.
# --------------------------------------------------
## セットアップ.
func setup(pos:Vector2, deg:float, speed:float, power:int) -> void:
	position = pos
	var rad = deg_to_rad(deg)
	_velocity.x = speed * cos(rad)
	_velocity.y = speed * -sin(rad)
	_power = power
	
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
