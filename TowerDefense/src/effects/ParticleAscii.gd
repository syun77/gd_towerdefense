extends Node2D

# ==================================================
# ASCII文字演出.
# ==================================================
# --------------------------------------------------
# const.
# --------------------------------------------------
const TIMER_VANISH = 1.0 # 1.0秒で消える.
const TIMER_START_VANISH = 0.5 # 消え始める時間.

# --------------------------------------------------
# onready.
# --------------------------------------------------
@onready var _label = $Label

# --------------------------------------------------
# vars.
# --------------------------------------------------
# 移動速度.
var _velocity = Vector2(0, -10)
# タイマー.
var _timer = 0.0

# --------------------------------------------------
# public functions.
# --------------------------------------------------
## 初期化.
func init(pos:Vector2, s:String, sc:float) -> void:
	position = pos
	_label.text = s	
	scale = Vector2.ONE * sc

# --------------------------------------------------
# private functions.
# --------------------------------------------------
## 更新.
func _process(delta: float) -> void:
	position += _velocity * delta
	_timer += delta
	if _timer > TIMER_START_VANISH:
	
		var rate = (_timer - TIMER_START_VANISH) / TIMER_START_VANISH
		modulate.a = 1.0 - rate # 透過で消す.
	
	if _timer >= TIMER_VANISH:
		queue_free()
