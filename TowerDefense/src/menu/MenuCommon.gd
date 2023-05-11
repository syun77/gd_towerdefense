extends Control
# =========================================
# メニュー共通.
# =========================================
class_name MenuCommon

# -----------------------------------------
# const.
# -----------------------------------------
const TIMER_FADE = 0.5
const FADE_ALPHA = 0.5

enum eResult {
	NONE,
	CANCEL,

	# 購入.
	BUY_NORMAL, # 通常の砲台
	BUY_LASER, # レーザー砲台.
	BUY_HORMING, # ホーミング砲台.
	
	# アップグレード.
	UG_RANGE, # 射程範囲.
	UG_DAMAGE, # 攻撃力.
	UG_FIRERATE, # 発射間隔.
}

# -----------------------------------------
# private var.
# -----------------------------------------
var _result = eResult.NONE
var _fade_timer = 0.0

# -----------------------------------------
# public function.
# -----------------------------------------
## 閉じたかどうか.
func closed() -> bool:
	return _result != eResult.NONE

## 結果を取得する.
func get_result() -> eResult:
	return _result

# -----------------------------------------
# private function.
# -----------------------------------------
## 背景の更新.
func _update_bg(color_rect:ColorRect, delta:float) -> void:
	_fade_timer = min(TIMER_FADE, _fade_timer + delta)
	var rate = _fade_timer / TIMER_FADE
	color_rect.modulate.a = FADE_ALPHA * rate
	color_rect.visible = true
