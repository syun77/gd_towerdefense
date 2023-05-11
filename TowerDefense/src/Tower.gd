extends Area2D
# ==================================================
# 砲台シーン.
# ==================================================
class_name Tower

# --------------------------------------------------
# const.
# --------------------------------------------------
# 選択したときのポップアップ出現時間.
const SELECTED_TIMER = 0.5

# レベルに対応する色.
const MAX_LV_COLOR = 5 # 最大レベル.
const LV_COLORS = {
#	1: Color.PALE_TURQUOISE,
	1: Color.WHITE,
	2: Color.LIME_GREEN,
	3: Color.ROSY_BROWN,
	4: Color.ORANGE,
	MAX_LV_COLOR: Color.ORANGE_RED,
}

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
@onready var _help_label = $Help/Label

# --------------------------------------------------
# private var.
# --------------------------------------------------
var _type = Game.eTower.NORMAL # タワーの種類.
var _timer = 0.0
var _selected_timer = 0.0 # ポップアップタイマー.

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
	
	# 画面外に出ないように調整.
	var dx = 824 - position.x
	if dx < 0:
		_help.position.x += dx
	var dy = 128 - position.y
	if dy > 0:
		_help.position.y += dy
		

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
	_spr.rotation = PI # 左向き.
	_help.visible = false

## 更新.
func _process(_delta: float) -> void:
	# ヘルプの更新.
	_help_label.text = "POWER: Lv%d (dmg:%d)"%[power_lv, get_power()]
	_help_label.text += "\nRANGE: Lv%d (%1.0f)"%[range_lv, get_range()/8.0]
	_help_label.text += "\nFIRERATE: Lv%d (%1.1fsec)"%[firerate_lv, get_firerate()]
	
	# 色を更新.
	_update_color()
	
	# 描画.
	queue_redraw()
	
## 色を更新.
func _update_color() -> void:
	_spr.modulate = _get_tower_color()
	
func _get_tower_color() -> Color:
	# Lvの平均を求める.
	var avg = (power_lv + range_lv + firerate_lv) / 3.0
	var a:int = floor(avg) # 端数切捨て.
	var d = avg - a
	if a >= MAX_LV_COLOR:
		# 色が変化する最大レベル.
		return LV_COLORS[MAX_LV_COLOR]
	var b:int = ceil(avg) # 端数切り上げ.
	var color1:Color = LV_COLORS[a]
	var color2:Color = LV_COLORS[b]
	return color1.lerp(color2, d)

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
		Game.eTower.HORMING: 200.0,
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
		# ヘルプポップアップの表示.
		_help.visible = true
		var rate = 1.0 - Ease.expo_in(_selected_timer / SELECTED_TIMER)
		_help.scale = Vector2.ONE * rate
		# 射程範囲の描画.
		var range = get_range() * rate
		var color = Color.AQUA
		color.a = 0.3
		# 塗りつぶし円の描画.
		draw_circle(Vector2.ZERO, range, color)
		var color2 = Color.WHITE
		# 円をいくつか描画.
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
			# 選択開始.
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
