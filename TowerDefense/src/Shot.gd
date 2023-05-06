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

# --------------------------------------------------
# public function.
# --------------------------------------------------
## セットアップ.
func setup(pos:Vector2, deg:float, speed:float) -> void:
	position = pos
	var rad = deg_to_rad(deg)
	_velocity.x = speed * cos(rad)
	_velocity.y = speed * -sin(rad)
	
## 消滅.
func vansih() -> void:
	queue_free()

## 攻撃力.
func get_power() -> int:
	return 1

## 消滅する.
func vanish() -> void:
	queue_free()
	
## 手動更新.
func update_manual(delta:float) -> void:
	delta *= Common.game_speed
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
