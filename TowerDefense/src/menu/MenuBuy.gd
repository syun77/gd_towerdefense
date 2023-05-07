extends MenuCommon

## 開始.
func _ready() -> void:
	var cnt_normal = 0
	var cnt_laser = 0
	var cnt_horming = 0
	for tower in Common.get_layer("tower").get_children():
		var t:Tower = tower
		match t.get_type():
			Tower.eType.NORMAL:
				cnt_normal += 1
			Tower.eType.LASER:
				cnt_laser += 1
			Tower.eType.HORMING:
				cnt_horming += 1
	var cost_normal = Game.tower_cost(cnt_normal)
	var cost_laser = Game.tower_cost(cnt_laser)
	var cost_horming = Game.tower_cost(cnt_horming)
	
	# 所持金.
	var money = Common.money
	for button in $ButtonList.get_children():
		if not button is Button:
			continue
		var btn:Button = button
		match btn.name:
			"ButtonBuyNormal":
				btn.text = "通常 ($%d)"%cost_normal
				btn.disabled = money < cost_normal
			"ButtonBuyLaser":
				btn.text = "レーザー ($%d)"%cost_laser
				btn.disabled = money < cost_laser
			"ButtonBuyHorming":
				btn.text = "ホーミング ($%d)"%cost_horming
				btn.disabled = money < cost_horming

## 更新.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("right-click"):
		_result = eResult.CANCEL

## キャンセルボタン.
func _on_button_cancel_pressed() -> void:
	_result = eResult.CANCEL

## 通常砲台を購入.
func _on_button_buy_normal_pressed() -> void:
	_result = eResult.BUY_NORMAL

## レーザー砲台を購入.
func _on_button_buy_laser_pressed() -> void:
	_result = eResult.BUY_LASER

## ホーミング砲台を購入.
func _on_button_buy_horming_pressed() -> void:
	_result = eResult.BUY_HORMING
