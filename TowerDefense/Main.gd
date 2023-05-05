extends Node2D

const TANK_OBJ = preload("res://src/Tank.tscn")

@onready var _path2d = $Path2D

var _path_list = []

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("click"):
		var path = PathFollow2D.new()
		path.loop = false # ループしない.
		# 戦車を生成.
		var tank = TANK_OBJ.instantiate()
		path.add_child(tank)
		_path2d.add_child(path)
		print("start!")
	
	for path in _path2d.get_children():
		path.progress += 128 * delta
		if path.progress_ratio >= 1.0:
			path.queue_free()
			print("end!")
