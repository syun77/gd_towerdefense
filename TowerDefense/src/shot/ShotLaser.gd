extends Shot
# ==================================================
# レーザーシーン.
# ==================================================
class_name ShotLaser

# --------------------------------------------------
# const.
# --------------------------------------------------
const TIME_EXIST = 1.0 # 生存時間.
const START_VANISH = 0.5 # 消え始める時間.

# --------------------------------------------------
# public functions.
# --------------------------------------------------
## 更新.
func update_manual(delta: float) -> void:
	# 表示開始.
	visible = true
	# rotationは時計回りのようなので atan2 する.
	rotation = atan2(_velocity.y, _velocity.x)
	
	_timer += delta
	if _timer >= START_VANISH:
		# 消滅開始するとY軸を縮小.
		var rate = 1.0 - ((_timer - START_VANISH) / (TIME_EXIST-START_VANISH))
		scale.y = rate
		
	if _timer >= TIME_EXIST:
		# 時間で消滅.
		vanish()

# --------------------------------------------------
# private functions.
# --------------------------------------------------
func _ready() -> void:
	# 最初は消しておく.
	visible = false

