extends Shot

class_name ShotHorming

# --------------------------------------------------
# private vars.
# --------------------------------------------------

# --------------------------------------------------
# public function.
# --------------------------------------------------
func update_manual(delta:float) -> void:
	rotation = atan2(_velocity.y, _velocity.x)
	position += _velocity * delta
	
	var target = Common.search_nearest_enemy(position, 99999)
	if target != null:
		_update_horming(delta, target)	
	
	if Common.is_outside(self, 16):
		# 画面外に出た.
		vanish()

# --------------------------------------------------
# private function.
# --------------------------------------------------
func _update_horming(delta:float, target:Enemy) -> void:
	if delta <= 0:
		return
	var d = target.global_position - position
	var diff = Common.diff_angle(_deg, rad_to_deg(atan2(-d.y, d.x)))
	var rate = min(1.0, 0.1 * Common.game_speed)
	_deg += diff * rate
	set_velocity(_deg, _speed)
