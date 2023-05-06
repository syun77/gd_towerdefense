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

## 消滅する.
func vanish() -> void:
	queue_free()

# --------------------------------------------------
# private function.
# --------------------------------------------------
## 開始.
func _ready() -> void:
	pass

## 更新.
func _physics_process(delta: float) -> void:
	position += _velocity * delta
	
	if Common.is_outside(self, 16):
		# 画面外に出た.
		vanish()
