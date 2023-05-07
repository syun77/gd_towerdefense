extends Node

# ==================================================
# ゲームパラメータを定義するスクリプト.
# ==================================================
# --------------------------------------------------
# tower.
# --------------------------------------------------
## 射程範囲 (= 32 + 16 * lv).
func tower_range(lv:int) -> float:
	return 48 + (16 * lv)
## 攻撃威力 (= lv)
func tower_power(lv:int) -> int:
	return lv
## 発射間隔 (= 2sec * 0.9 ^ (lv-1))
func tower_firerate(lv:int) -> float:
	return 2.0 * pow(0.9, (lv-1))
	
## 製造コスト＝ 8 * (1.3 ^ 砲台の存在数)
func tower_cost(num:int) -> int:
	var base = 8
	var cost = 8 * pow(1.3, num)
	return cost
	
## 射程範囲のアップグレード
func tower_upgrade_range(lv:int) -> int:
	var cost = 10 * pow(1.5, (lv-1))
	return int(cost)
## 攻撃威力のアップグレード.
func tower_upgrade_power(lv:int) -> int:
	var cost = 20 * pow(1.5, (lv-1))
	return cost
## 発射間隔のアップグレード.
func tower_upgrade_firerate(lv:int) -> int:
	var cost = 15 * pow(1.5, (lv-1))
	return cost

# --------------------------------------------------
# enemy.
# --------------------------------------------------
## HP (base + (Wave数 / 3))
func enemy_hp(wave:int) -> int:
	var base = 2
	return base + floor(wave / 3) # 端数切捨て.

## 所持金.
func enemy_money(wave:int) -> int:
	if wave < 5:
		return 2
	return 1

## 出現間隔.
func enemy_interval(_wave:int) -> float:
	var base = 2.0
	var t = base - (_wave * 0.1)
	if t < 0.5:
		t = 0.5
	return t

## 出現数.
func enemy_spawn_number(wave:int) -> int:
	var base = 5
	return base + wave
	
## 移動速度.
func enemy_speed(wave:int) -> float:
	var base = 1.0
	return base + (wave * 0.05)
