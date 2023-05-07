extends Area2D
# ==================================================
# 砲台シーン.
# ==================================================
class_name Tower

# --------------------------------------------------
# const.
# --------------------------------------------------
enum eType {
	NORMAL,
	LASER,
	HORMING,
}

# --------------------------------------------------
# preload.
# --------------------------------------------------
var SHOT_OBJ = preload("res://src/Shot.tscn")

# --------------------------------------------------
# onready.
# --------------------------------------------------
@onready var _spr = $Sprite

# --------------------------------------------------
# private var.
# --------------------------------------------------
var _type = eType.NORMAL
var _timer = 0.0
var _range_lv = 1 # 射程範囲Lv.
var _power_lv = 1 # 攻撃力Lv.
var _firerate_lv = 1 # 発射間隔Lv.

# --------------------------------------------------
# public function.
# --------------------------------------------------
## 種類.
func get_type() -> eType:
	return _type
## 攻撃力.
func get_power() -> int:
	return Game.tower_power(_power_lv)
## 射程範囲.
func get_range() -> float:
	return Game.tower_range(_power_lv)
## 発射間隔.
func get_firerate() -> float:
	return Game.tower_firerate(_power_lv)

## セットアップ.
func setup(pos:Vector2) -> void:
	position = pos

## 手動更新.
func update_manual(delta:float) -> void:
	delta *= Common.game_speed
	_timer += delta

	# 一番近い敵を探す.
	var range = get_range()
	var enemy = Common.search_nearest_enemy(position, range)
	
	_update_rotate(enemy)
	
	var interval = get_firerate()
	if _timer >= interval:
		if _shot(enemy):
			# 発射できた.
			_timer = 0
	
	# 描画.
	queue_redraw()
	

# --------------------------------------------------
# private function.
# --------------------------------------------------
## 開始.
func _ready() -> void:
	_spr.rotation = PI

## 更新 > 回転.
func _update_rotate(enemy:Enemy) -> void:
	if enemy == null:
		return # 更新不要.
	
	var d = enemy.global_position - position
	var rad = d.angle()
	
	_spr.rotation = lerp_angle(_spr.rotation, rad, 0.3)

## ショットを発射する.
func _shot(enemy:Enemy) -> bool:
	if enemy == null:
		return false # 対象なし.
	
	var d = enemy.global_position - position
	var deg = rad_to_deg(atan2(-d.y, d.x))
	
	var shot = SHOT_OBJ.instantiate()
	Common.get_layer("shot").add_child(shot)
	var power = get_power()
	shot.setup(position, deg, 200, power)
	
	return true

## 描画.
func _draw() -> void:
	if selected:
		# 射程範囲の描画.
		var range = get_range()
		draw_arc(Vector2.ZERO, range, 0, 2*PI, 32, Color.AQUA)

# --------------------------------------------------
# property function.
# --------------------------------------------------
## 選択しているかどうか.
var selected = false:
	set(v):
		selected = v
	get:
		return selected
