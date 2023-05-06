extends MenuCommon

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
