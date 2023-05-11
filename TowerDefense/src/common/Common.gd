extends Node
# ==================================================
# 共通モジュール.
# ==================================================

# --------------------------------------------------
# const.
# --------------------------------------------------
const INIT_MONEY = 20
const INIT_WAVE = 0 # 最初に+1するので0始まり.
const INIT_HP = 9 # 拠点の初期HP.

# --------------------------------------------------
# preload.
# --------------------------------------------------
const PARTICLE_OBJ  = preload("res://src/effects/Particle.tscn")
const ASCII_OBJ = preload("res://src/effects/ParticleAscii.tscn")


# --------------------------------------------------
# private vars.
# --------------------------------------------------
var _money = INIT_MONEY
var _layers = {}
var _wave = INIT_WAVE # Wave数.

# --------------------------------------------------
# public functions.
# --------------------------------------------------
func init() -> void:
	reset_money()
	reset_hp()
	reset_wave()

func setup(layers:Dictionary) -> void:
	_layers = layers

func get_layer(name:String) -> CanvasLayer:
	return _layers[name]

## 敵は CanvasLayer > Path2D > PathFollow2D の子なので仕方なし.
## @note 頻繁に呼び出すならキャッシュが必要かもしれない.
func get_enemies() -> Array[Enemy]:
	var ret:Array[Enemy] = []
	var enemies = get_layer("enemy")
	for path2d in enemies.get_children():
		for paht_follow in path2d.get_children():
			for child in paht_follow.get_children():
				ret.append(child)
	return ret

## 指定の座標から一番近い敵を探す.
## @param pos 基準の位置.
## @param range 射的距離.
func search_nearest_enemy(pos:Vector2, range:float) -> Enemy:
	var enemies = get_enemies()
	var dist = 99999
	var ret:Enemy = null
	for enemy in enemies:
		var dist2 = enemy.global_position.distance_to(pos)
		dist2 -= enemy.get_size() # 半径を考慮する.
		if dist2 < dist:
			# より近い.
			dist = dist2
			if dist <= range:
				# 射程範囲内.
				ret = enemy
	return ret

## 画面外チェック.
func is_outside(node:Node2D, size:float) -> bool:
	var rect = node.get_viewport_rect()
	var pos = node.position
	if pos.x < -size:
		return true
	if pos.y < -size:
		return true
	if pos.x > rect.size.x + size:
		return true
	if pos.y > rect.size.y + size:
		return true
	return false

## 角度差を求める.
func diff_angle(now:float, next:float) -> float:
	# 角度差を求める.
	var d = next - now
	# 0.0〜360.0にする.
	d -= floor(d / 360.0) * 360.0
	# -180.0〜180.0の範囲にする.
	if d > 180.0:
		d -= 360.0
	return d
	
func add_particle() -> Particle:
	var parent = get_layer("particle")
	var p = PARTICLE_OBJ.instantiate()
	parent.add_child(p)
	return p


func start_particle(pos:Vector2, time:float, color:Color, sc:float=1.0) -> void:
	var deg = randf_range(0, 360)
	for i in range(8):
		var p = add_particle()
		p.position = pos
		var speed = randf_range(100, 1000)
		var t = time + randf_range(-0.2, 0.2)
		var ax = 0.0
		var ay = 3.0
		p.start(t, deg, speed, ax, ay, color, sc)
		deg += randf_range(30, 50)

func start_particle_ring(pos:Vector2, time:float, color:Color, sc:float=2.0) -> void:
	var p = add_particle()
	p.position = pos
	p.start_ring(time, color, sc)

func start_particle_enemy(pos:Vector2, time:float, color:Color) -> void:
	start_particle(pos, time, color, 2.0)
	for i in range(3):
		start_particle_ring(pos, time + (i * 0.2), color, pow(2.0, (1 + i)))
		
func add_ascii(pos:Vector2, s:String, sc:float=1.0) -> void:
	var p = ASCII_OBJ.instantiate()
	get_layer("particle").add_child(p)
	p.init(pos, s, sc)

func add_money(v:int) -> void:
	_money += v
func spend_money(v:int) -> void:
	_money -= v
func reset_money() -> void:
	_money = INIT_MONEY

func next_wave() -> void:
	_wave += 1
func reset_wave() -> void:
	_wave = INIT_WAVE
	
func reset_hp() -> void:
	health = INIT_HP
func damage_hp(v:int) -> void:
	health -= v
func is_dead() -> bool:
	return health <= 0

# --------------------------------------------------
# properties.
# --------------------------------------------------
## 所持金.
var money:
	set(v):
		assert("can't call")
	get:
		return _money

## Wave数
var wave:
	set(v):
		assert("can't call")
	get:
		return _wave

## ゲーム速度.
var game_speed = 1.0:
	set(v):
		game_speed = v
	get:
		return game_speed

## 拠点HP
var health = INIT_HP:
	set(v):
		if health > v:
			is_damage = true
		health = v
		if health < 0:
			health = 0
	get:
		return health
var is_damage = false:
	set(b):
		is_damage = b
	get:
		return is_damage
