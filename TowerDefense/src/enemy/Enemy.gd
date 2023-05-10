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
const TIMER_SHAKE = 0.5

# --------------------------------------------------
# onready.
# --------------------------------------------------
@onready var _spr = $AnimatedSprite2D
@onready var _mask = $Mask
@onready var _ui_health = $Health
@onready var _health_bar = $Health/HealthBar

# --------------------------------------------------
# private var.
# --------------------------------------------------
# PathFollow2Dが親となる.
var _parent:PathFollow2D = null

var _hp:int = 0
var _max_hp:int = 0
var _speed:float = 1.0

var _prev_pos = Vector2()
var _timer_shake = 0.0
var _cnt = 0

# --------------------------------------------------
# public function.
# --------------------------------------------------
## サイズ.
func get_size() -> float:
	return 32.0

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

	# HPの設定.
	var hp = Game.enemy_hp(Common.wave)	
	set_hp(hp)
	
	# 速度の設定.
	_speed = Game.enemy_speed(Common.wave)
	
## HPを設定.
func set_hp(v:int) -> void:
	_hp = v
	_max_hp = v

## HPの割合を取得する.
func get_hpratio() -> float:
	return 1.0 * _hp / _max_hp

## ダメージ処理.
func damage(shot:Shot) -> void:
	# ヒット演出.
	_hit_effect(shot)
	
	_timer_shake = TIMER_SHAKE
	var power = shot.get_power()
	_hp -= power
	if _hp <= 0:
		# 消滅.
		vanish()
		# お金ゲット!
		var money = Game.enemy_money(Common.wave)
		Common.add_money(money)
		
		# パーティクルを生成.
		var pos = global_position
		var time = 1.0
		var color = Color.LIME
		Common.start_particle_enemy(pos, time, color)
		Common.start_particle_ring(pos, time, color)

## 消滅.
func vanish() -> void:
	# 親を消すことで自身も消える.
	_parent.queue_free()
	
## 手動更新 (_process()は使わない).
func update_manual(delta:float) -> void:
	_cnt += 1
	
	# 移動処理
	_parent.progress += MOVE_SPEED * _speed * delta
	
	# 回転処理.
	_update_rotate()
	
	# 揺れ処理.
	if delta > 0:
		_update_shake(delta)
	
	# 終了チェック.
	if _parent.progress_ratio >= 1.0:
		# ダメージを与えた.
		Common.damage_hp(1)
		vanish()
		return

	# HPバーの更新.
	_update_health_bar()
	

# --------------------------------------------------
# private function.
# --------------------------------------------------
## 開始.
func _ready() -> void:
	# 体力ゲージは消しておく.
	_ui_health.visible = false

## 回転処理.
func _update_rotate():
	var pos = _parent.position
	var d = pos - _prev_pos
	var angle = lerp_angle(_spr.rotation, d.angle(), 0.1*Common.game_speed)
	_spr.rotation = angle
	_mask.rotation = angle
	_prev_pos = pos

## HPバーの更新.
func _update_health_bar() -> void:
	var rate = get_hpratio()
	if rate < 1.0:
		_ui_health.visible = true
		_health_bar.value = 100 * rate
		
## 揺れ処理.
func _update_shake(delta:float) -> void:
	if _timer_shake <= 0:
		return
	
	_timer_shake -= delta
	var rate = _timer_shake / TIMER_SHAKE
	var red = Color.RED
	red.a = rate
	if _cnt%4 < 2:
		red.a = 0
	_mask.modulate = red
	_mask.visible = true
	
	var xofs = 2 * rate
	if _cnt%4 < 2:
		xofs *= -1
	var yofs = 1 * rate * randi_range(-1, 1)
	_spr.offset.x = xofs
	_spr.offset.y = yofs
	
	if _timer_shake <= 0:
		# 終了.
		_spr.offset = Vector2.ZERO
		_mask.visible = false

func is_shot(obj) -> bool:
	if obj is Shot:
		return true
	
	return false

## ヒットエフェクト再生.
func _hit_effect(shot:Shot) -> void:
	if shot.get_tower_type() == Game.eTower.LASER:
		return # TODO: レーダーは未実装.

	var pos = shot.position
	# 敵に少し近づける.
	pos += (global_position - pos) * 0.8
	
	var deg = shot._deg
	# 逆方向にする.
	deg += 180
	for i in range(8):
		var deg2 = deg + randf_range(-45, 45)
		var speed = randf_range(180, 300)
		var p = Common.add_particle()
		p.position = pos
		# 生存時間.
		var t = randf_range(0.8, 1.2)
		# スケール値.
		var sc = randf_range(1.0, 2.0)
		# 加速度.
		var ax = 0.0
		var ay = 0.0
		p.start(t, deg2, speed, ax, ay, Color.LIME, sc)

# --------------------------------------------------
# signal function.
# --------------------------------------------------
## 衝突.
func _on_area_entered(area: Area2D) -> void:
	if is_shot(area):
		# ダメージ処理.
		var shot = area as Shot
		damage(shot)
		
		if shot.get_tower_type() != Game.eTower.LASER:
			# レーザー以外は消しておく.
			shot.vanish()
