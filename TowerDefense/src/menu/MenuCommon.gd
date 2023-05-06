extends Control
# =========================================
# メニュー共通.
# =========================================
class_name MenuCommon

# -----------------------------------------
# const.
# -----------------------------------------
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

# -----------------------------------------
# private function.
# -----------------------------------------
## 閉じたかどうか.
func closed() -> bool:
	return _result != eResult.NONE

## 結果を取得する.
func get_result() -> eResult:
	return _result
