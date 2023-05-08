extends MenuCommon

var _cnt = 0
var _tower:Tower # アップグレード対象のタワー.

## セットアップ.
func setup(tower:Tower) -> void:
	_tower = tower

## ボタンの更新.
func _refresh_buttons() -> void:
	var lv_power = _tower.power_lv
	var lv_range = _tower.range_lv
	var lv_firerate = _tower.firerate_lv
	var type = _tower.get_type()
	var cost_power = Game.tower_upgrade_power(lv_power, type)
	var cost_range = Game.tower_upgrade_range(lv_range, type)
	var cost_firerate = Game.tower_upgrade_firerate(lv_firerate, type)
	
	# 所持金.
	var money = Common.money
	for button in $ButtonList.get_children():
		if not button is Button:
			continue
		var btn:Button = button
		match btn.name:
			"ButtonBuyPower":
				btn.text = "攻撃力 Lv%d > Lv%d($%d)"%[lv_power, lv_power+1, cost_power]
				btn.disabled = money < cost_power
			"ButtonBuyRange":
				btn.text = "射程範囲 Lv%d > Lv%d ($%d)"%[lv_range, lv_range+1, cost_range]
				btn.disabled = money < cost_range
			"ButtonBuyFirerate":
				btn.text = "発射間隔 Lv%d > Lv%d ($%d)"%[lv_firerate, lv_firerate+1, cost_firerate]
				btn.disabled = money < cost_firerate
	

## 開始.
func _ready() -> void:
	_refresh_buttons()

## 更新.
func _process(_delta: float) -> void:
	_cnt += 1
	
	if _cnt > 1: # 初回は処理しない.
		if Input.is_action_just_pressed("right-click"):
			_result = eResult.CANCEL

## キャンセルボタン.
func _on_button_cancel_pressed() -> void:
	_result = eResult.CANCEL

func _on_button_buy_power_pressed() -> void:
	_tower.power_lv += 1
	_refresh_buttons()

func _on_button_buy_range_pressed() -> void:
	_tower.range_lv += 1
	_refresh_buttons()

func _on_button_buy_firerate_pressed() -> void:
	_tower.firerate_lv += 1
	_refresh_buttons()
