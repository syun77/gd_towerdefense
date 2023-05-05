extends Node2D

# 移動速度。64px/s
const MOVE_SPEED = 64.0

# PathFollow2Dが親となる.
var _parent:PathFollow2D = null

## セットアップ.
func setup(path2d:Path2D) -> void:
	_parent = PathFollow2D.new()
	_parent.loop = false # ループしない.
	_parent.add_child(self) # 自身を登録する.
	
	# Path2Dに登録する.
	path2d.add_child(_parent)
	
	$AnimatedSprite2D.play("default")

## 更新.
func _physics_process(delta: float) -> void:
	# 可変.
	delta *= Common.game_speed
	
	# 移動処理
	_parent.progress += MOVE_SPEED * delta
	
	# 終了チェック.
	if _parent.progress_ratio >= 1.0:
		# 親を消すことで自身も消える.
		_parent.queue_free()
		print("end!")
