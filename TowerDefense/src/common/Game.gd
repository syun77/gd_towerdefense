extends Node

# ==================================================
# ゲームパラメータを定義するスクリプト.
# ==================================================
const DAMAGE_BASE = 1000

enum eTower {
	NORMAL, # 通常.
	LASER, # レーザー.
	HORMING, # ホーミング.
}

# --------------------------------------------------
# tower.
# --------------------------------------------------
## 射程範囲 (= 32 + 16 * lv).
func tower_range(lv:int, type:eTower) -> float:
	match type:
		eTower.LASER:
			return 48 + (8 * lv)
		eTower.HORMING:
			return 64 + (16 * lv)
		_: #eTower.NORMAL:
			return 48 + (16 * lv)
		
## 攻撃威力 (= lv * 100)
func tower_power(lv:int, type:eTower) -> int:
	match type:
		eTower.LASER:
			return 10 + (lv * 2)
		eTower.HORMING:
			return int(lv * DAMAGE_BASE * 0.5)
		_: #eTower.NORMAL:
			return lv * DAMAGE_BASE
## 発射間隔 (= 2sec * 0.9 ^ (lv-1))
func tower_firerate(lv:int, type:eTower) -> float:
	match type:
		eTower.LASER:
			return 3.0 * pow(0.9, (lv-1))
		eTower.HORMING:
			return 1.5 * pow(0.9, (lv-1))
		_: #eTower.NORMAL:
			return 2.0 * pow(0.9, (lv-1))
	
## 製造コスト＝ 8 * (1.3 ^ 砲台の存在数)
func tower_cost(num:int, type:eTower) -> int:
	match type:
		eTower.LASER:
			var base = 25
			var cost = base * pow(1.3, num)
			return cost
		eTower.HORMING:
			var base = 15
			var cost = base * pow(1.3, num)
			return cost
		_: #eTower.NORMAL:
			var base = 8
			var cost = base * pow(1.3, num)
			return cost
	
## 射程範囲のアップグレード
func tower_upgrade_range(lv:int, type:eTower) -> int:
	match type:
		eTower.LASER:
			var cost = 20 * pow(1.5, (lv-1))
			return int(cost)
		eTower.HORMING:
			var cost = 8 * pow(1.5, (lv-1))
			return int(cost)
		_: #eTower.NORMAL:
			var cost = 10 * pow(1.5, (lv-1))
			return int(cost)
## 攻撃威力のアップグレード.
func tower_upgrade_power(lv:int, type:eTower) -> int:
	match type:
		eTower.LASER:
			var cost = 15 * pow(1.5, (lv-1))
			return int(cost)
		eTower.HORMING:
			var cost = 40 * pow(1.5, (lv-1))
			return int(cost)
		_: #eTower.NORMAL:
			var cost = 20 * pow(1.5, (lv-1))
			return int(cost)
## 発射間隔のアップグレード.
func tower_upgrade_firerate(lv:int, type:eTower) -> int:
	match type:
		eTower.LASER:
			var cost = 40 * pow(1.5, (lv-1))
			return int(cost)
		eTower.HORMING:
			var cost = 20 * pow(1.5, (lv-1))
			return int(cost)
		_: #eTower.NORMAL:
			var cost = 15 * pow(1.5, (lv-1))
			return int(cost)

## タワーテクスチャのパスを取得する.
func tower_texture_path(type:eTower) -> String:
	var tbl = {
		Game.eTower.NORMAL: "res://assets/images/tower.png",
		Game.eTower.LASER: "res://assets/images/tower_laser.png",
		Game.eTower.HORMING: "res://assets/images/tower_horming.png",
	}
	return tbl[type]

# --------------------------------------------------
# enemy.
# --------------------------------------------------
## HP (base + (Wave数 / 3))
func enemy_hp(wave:int) -> int:
	var base = 2.0
	var hp = base + floor(wave / 3.0)
	return int(hp * DAMAGE_BASE)

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
