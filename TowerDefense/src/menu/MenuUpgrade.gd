extends MenuCommon
# ==================================================
# アップグレードメニュー.
# ==================================================
# --------------------------------------------------
# vars.
# --------------------------------------------------
var _cnt = 0
var _tower:Tower # アップグレード対象のタワー.
var _cost_power:int = 0
var _cost_range:int = 0
var _cost_firerate:int = 0

# --------------------------------------------------
# public functions.
# --------------------------------------------------
## セットアップ.
func setup(tower:Tower) -> void:
	_tower = tower

# --------------------------------------------------
# private functions.
# --------------------------------------------------
## ボタンの更新.
func _refresh_buttons() -> void:
	var lv_power = _tower.power_lv
	var lv_range = _tower.range_lv
	var lv_firerate = _tower.firerate_lv
	var type = _tower.get_type()
	_cost_power = Game.tower_upgrade_power(lv_power, type)
	_cost_range = Game.tower_upgrade_range(lv_range, type)
	_cost_firerate = Game.tower_upgrade_firerate(lv_firerate, type)
	
	# 所持金.
	var money = Common.money
	for button in $ButtonList.get_children():
		if not button is Button:
			continue
		var btn:Button = button
		match btn.name:
			"ButtonBuyPower":
				btn.text = "攻撃力 Lv%d > Lv%d($%d)"%[lv_power, lv_power+1, _cost_power]
				btn.disabled = money < _cost_power
			"ButtonBuyRange":
				btn.text = "射程範囲 Lv%d > Lv%d ($%d)"%[lv_range, lv_range+1, _cost_range]
				btn.disabled = money < _cost_range
			"ButtonBuyFirerate":
				btn.text = "発射間隔 Lv%d > Lv%d ($%d)"%[lv_firerate, lv_firerate+1, _cost_firerate]
				btn.disabled = money < _cost_firerate
	

## 開始.
func _ready() -> void:
	_refresh_buttons()

## 更新.
func _process(delta: float) -> void:
	# 暗転背景の更新.
	_update_bg($ColorRect, delta)
	
	_cnt += 1
	
	if _cnt > 1: # 初回は処理しない.
		if Input.is_action_just_pressed("right-click"):
			_result = eResult.CANCEL

# --------------------------------------------------
# signal functions.
# --------------------------------------------------
## キャンセルボタン.
func _on_button_cancel_pressed() -> void:
	_result = eResult.CANCEL

func _on_button_buy_power_pressed() -> void:
	_tower.power_lv += 1
	# お金を減らす.
	Common.spend_money(_cost_power)
	Common.play_se("upgrade")
	_refresh_buttons()

func _on_button_buy_range_pressed() -> void:
	_tower.range_lv += 1
	# お金を減らす.
	Common.spend_money(_cost_range)
	Common.play_se("upgrade")
	_refresh_buttons()

func _on_button_buy_firerate_pressed() -> void:
	_tower.firerate_lv += 1
	# お金を減らす.
	Common.spend_money(_cost_firerate)
	Common.play_se("upgrade")
	_refresh_buttons()
