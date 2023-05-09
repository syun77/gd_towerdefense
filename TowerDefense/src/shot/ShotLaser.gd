extends Shot

const TIME_EXIST = 1.0
const START_VANISH = 0.5

func _ready() -> void:
	visible = false

func update_manual(delta: float) -> void:
	visible = true
	rotation = atan2(_velocity.y, _velocity.x)
	
	_timer += delta
	if _timer >= START_VANISH:
		var rate = 1.0 - ((_timer - START_VANISH) / (TIME_EXIST-START_VANISH))
		scale.y = rate
		
	if _timer >= TIME_EXIST:
		# 時間で消滅.
		vanish()
