extends Area2D
# ==================================================
# 砲台シーン.
# ==================================================
class_name Tower

# --------------------------------------------------
# const.
# --------------------------------------------------
const SELECTED_TIMER = 0.5

# --------------------------------------------------
# preload.
# --------------------------------------------------
const SHOT_OBJ = preload("res://src/shot/Shot.tscn")
const LASER_OBJ = preload("res://src/shot/ShotLaser.tscn")
const HORMING_OBJ = preload("res://src/shot/ShotHorming.tscn")

# --------------------------------------------------
# onready.
# --------------------------------------------------
@onready var _spr = $Sprite
@onready var _help = $Help
@onready var _helo_label = $Help/Label

# --------------------------------------------------
# private var.
# --------------------------------------------------
var _type = Game.eTower.NORMAL
var _timer = 0.0
var _selected_timer = 0.0

# --------------------------------------------------
# public function.
# --------------------------------------------------
## 種類.
func get_type() -> Game.eTower:
	return _type
## 攻撃力.
func get_power() -> int:
	return Game.tower_power(power_lv, _type)
## 射程範囲.
func get_range() -> float:
	return Game.tower_range(range_lv, _type)
## 発射間隔.
func get_firerate() -> float:
	return Game.tower_firerate(firerate_lv, _type)

## セットアップ.
func setup(pos:Vector2, type:Game.eTower) -> void:
	position = pos
	_set_type(type)

## 手動更新.
func update_manual(delta:float) -> void:
	_timer += delta
	
	_selected_timer = max(0, _selected_timer - delta)

	# 一番近い敵を探す.
	var range = get_range()
	var enemy = Common.search_nearest_enemy(position, range)
	
	_update_rotate(enemy)
	
	var interval = get_firerate()
	if _timer >= interval:
		if _shot(enemy):
			# 発射できた.
			_timer = 0

	

# --------------------------------------------------
# private function.
# --------------------------------------------------
## 開始.
func _ready() -> void:
	_spr.rotation = PI
	_help.visible = false

## 更新.
func _process(_delta: float) -> void:
	# ヘルプの更新.
	_helo_label.text = "POWER: LV%d"%power_lv
	_helo_label.text += "\nRANGE: LV%d"%range_lv
	_helo_label.text += "\nFIRERATE: LV%d"%firerate_lv
		
	# 描画.
	queue_redraw()

## タワーの種別を設定
func _set_type(type:Game.eTower) -> void:
	_type = type
	var path = Game.tower_texture_path(_type)
	_spr.texture = load(path)

## 更新 > 回転.
func _update_rotate(enemy:Enemy) -> void:
	if enemy == null:
		return # 更新不要.
	
	var d = enemy.global_position - position
	var rad = d.angle()
	
	var rate = min(1.0, 0.3*Common.game_speed)
	_spr.rotation = lerp_angle(_spr.rotation, rad, rate)

## ショットを発射する.
func _shot(enemy:Enemy) -> bool:
	if enemy == null:
		return false # 対象なし.
	
	var d = enemy.global_position - position
	var deg = rad_to_deg(atan2(-d.y, d.x))
	
	var tbl = {
		Game.eTower.NORMAL: SHOT_OBJ,
		Game.eTower.LASER: LASER_OBJ,
		Game.eTower.HORMING: HORMING_OBJ,
	}
	var tbl2 = {
		Game.eTower.NORMAL: 200.0,
		Game.eTower.LASER: 1, # 動かないけど角度は必要なので "1".
		Game.eTower.HORMING: 150.0,
	}
	var speed = tbl2[_type]	
	var shot = tbl[_type].instantiate()
	Common.get_layer("shot").add_child(shot)
	var power = get_power()
	shot.setup(position, deg, speed, power, _type)
	
	return true

## 描画.
func _draw() -> void:
	_help.visible = false
	if selected:
		_help.visible = true
		# 射程範囲の描画.
		var rate = 1.0 - Ease.expo_in(_selected_timer / SELECTED_TIMER)
		_help.scale = Vector2.ONE * rate
		var range = get_range() * rate
		var color = Color.AQUA
		color.a = 0.3
		draw_circle(Vector2.ZERO, range, color)
		var color2 = Color.WHITE
		for ofs in [0, 0.1, 0.2]:
			var rate2 = fmod((_timer + ofs) * 0.5, 1.0)
			color2.a = 1.0 - rate2
			draw_arc(Vector2.ZERO, range*Ease.expo_out(rate2), 0, 2*PI, 32, color2)

# --------------------------------------------------
# property function.
# --------------------------------------------------
## 選択しているかどうか.
var selected = false:
	set(v):
		if selected == false and v:
			_selected_timer = SELECTED_TIMER
		selected = v
	get:
		return selected

var range_lv = 1: # 射程範囲Lv.
	set(v):
		range_lv = v
	get:
		return range_lv
var power_lv = 1: # 攻撃力Lv.
	set(v):
		power_lv = v
	get:
		return power_lv
var firerate_lv = 1: # 発射間隔Lv.
	set(v):
		firerate_lv = v
	get:
		return firerate_lv
