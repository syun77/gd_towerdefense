extends Node2D

const ENEMY_OBJ = preload("res://src/Enemy.tscn")

@onready var _path2d = $Path2D
# UI.
@onready var _ui_game_speed  = $UILayer/HSliderGameSpeed
@onready var _ui_game_speed_label = $UILayer/HSliderGameSpeed/Label

var _path_list = []

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("click"):
		# 敵を生成.
		var enemy = ENEMY_OBJ.instantiate()
		enemy.setup(_path2d)
		
	# UIの更新.
	_update_ui()

## 更新 > UI.
func _update_ui() -> void:
	Common.game_speed = _ui_game_speed.value
	_ui_game_speed_label.text = "SPEED x%3.1f"%Common.game_speed
