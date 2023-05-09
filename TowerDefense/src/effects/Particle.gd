extends Sprite2D
# ==================================================
# パーティクル.
# ==================================================
class_name Particle

# --------------------------------------------------
# const.
# --------------------------------------------------
const RING_TEXTURE = preload("res://assets/images/ring.png")
const SCALE_BASE = 0.1

enum eType {
	NORMAL,
	RING,
}

# --------------------------------------------------
# vars.
# --------------------------------------------------
var _type = eType.NORMAL
var _velocity = Vector2.ZERO
var _accel = Vector2.ZERO
var _timer := 0.0
var _timer_max := 1.0
var _scale_rate:float = 1.0

# --------------------------------------------------
# public functions.
# --------------------------------------------------
func start(t:float, deg:float, speed:float, ax:float, ay:float, color:Color, sc:float) -> void:
	_type = eType.NORMAL
	var rad = deg_to_rad(deg)
	_velocity.x = cos(rad) * speed
	_velocity.y = -sin(rad) * speed
	_accel.x = ax
	_accel.y = ay
	_scale_rate = sc * SCALE_BASE
	set_time(t)
	modulate = color

func start_ring(t:float, color:Color, sc:float) -> void:
	_type = eType.RING
	texture = RING_TEXTURE #load(PATH_RING)
	set_time(t)
	_scale_rate = sc * SCALE_BASE
	modulate = color
	scale = Vector2.ZERO

func set_time(t:float) -> void:
	_timer = t
	_timer_max = t	

# --------------------------------------------------
# private functions.
# --------------------------------------------------
func _process(delta: float) -> void:
	_velocity += _accel
	_velocity *= 0.95 # 減衰
	position += _velocity * delta
		
	_timer -= delta
	if _timer <= 0:
		queue_free()
		return
	
	# 拡大・縮小を設定.
	var rate = _timer / _timer_max
	match _type:
		eType.RING:
			# リングは拡大する.
			rate = Ease.expo_out(1.0 - rate)
			var sc = rate * _scale_rate
			scale = Vector2(sc, sc)
			modulate.a = 1.0 - rate

		_:
			# 縮小する.
			var sc = rate * _scale_rate
			scale.x = sc
			scale.y = sc
	
