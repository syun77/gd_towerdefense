extends Area2D
# ==================================================
# 砲台シーン.
# ==================================================
class_name Tower

# --------------------------------------------------
# const.
# --------------------------------------------------

# --------------------------------------------------
# preload.
# --------------------------------------------------
var SHOT_OBJ = preload("res://src/Shot.tscn")

# --------------------------------------------------
# preload.
# --------------------------------------------------
@onready var _spr = $Sprite

# --------------------------------------------------
# private var.
# --------------------------------------------------
var _timer = 0.0
var _interval = 3.0
var _range = 128.0 # 射程範囲.

# --------------------------------------------------
# public function.
# --------------------------------------------------
func setup() -> void:
	pass

# --------------------------------------------------
# private function.
# --------------------------------------------------
## 開始.
func _ready() -> void:
	_spr.rotation = PI

## 更新.
func _physics_process(delta: float) -> void:
	_timer += delta

	# 一番近い敵を探す.
	var enemy = Common.search_nearest_enemy(position, _range)
	
	_update_rotate(enemy)
	
	if _timer >= _interval:
		if _shot(enemy):
			# 発射できた.
			_timer = 0
	
	# 描画.
	queue_redraw()

## 更新 > 回転.
func _update_rotate(enemy:Enemy) -> void:
	if enemy == null:
		return # 更新不要.
	
	var d = enemy.global_position - position
	var rad = d.angle()
	
	_spr.rotation = lerp_angle(_spr.rotation, rad, 0.1)

## ショットを発射する.
func _shot(enemy:Enemy) -> bool:
	if enemy == null:
		return false # 対象なし.
	
	var d = enemy.global_position - position
	var deg = rad_to_deg(atan2(-d.y, d.x))
	print(deg)
	
	var shot = SHOT_OBJ.instantiate()
	Common.get_layer("shot").add_child(shot)
	shot.setup(position, deg, 200)
	
	return true

## 描画.
func _draw() -> void:
	# 射程範囲の描画.
	draw_arc(Vector2.ZERO, _range, 0, 2*PI, 32, Color.AQUA)
