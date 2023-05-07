extends Node2D
# ==================================================
# Wave開始演出.
# ==================================================

# --------------------------------------------------
# const.
# --------------------------------------------------
const TIMER_SLIDE = 1.0
const TIMER_WAIT = 0.1
const MOVE_DISTANCE = 800.0

enum eState {
	SLIDE_IN,
	WAIT,
	SLIDE_OUT,
}

# --------------------------------------------------
# onready.
# --------------------------------------------------
@onready var _bg = $Bg
@onready var _caption = $Caption
@onready var _caption_label = $Caption/LabelCaption

# --------------------------------------------------
# vars.
# --------------------------------------------------
var _state = eState.SLIDE_IN
var _timer = 0.0

# --------------------------------------------------
# private functions.
# --------------------------------------------------
func _ready() -> void:
	_caption.visible = false
	_bg.scale.y = 0.0
	
func _process(delta: float) -> void:
	_caption.visible = true
	_caption_label.text = "WAVE %d"%Common.wave
	match _state:
		eState.SLIDE_IN:
			_timer += delta
			var rate = 1.0 - (_timer / TIMER_SLIDE)
			_bg.scale.y = Ease.expo_out(1.0 - rate)
			_caption.position.x = -MOVE_DISTANCE * Ease.expo_in(rate)
			if _timer >= TIMER_SLIDE:
				_state = eState.WAIT
				_timer = 0
		eState.WAIT:
			_timer += delta
			_caption.position.x = 0
			if _timer >= TIMER_WAIT:
				_state = eState.SLIDE_OUT
				_timer = 0
		eState.SLIDE_OUT:
			_timer += delta
			var rate = (_timer / TIMER_SLIDE)
			_bg.scale.y = Ease.expo_out(1.0 - rate)
			_caption.position.x = MOVE_DISTANCE * Ease.expo_in(rate)
			if _timer >= TIMER_SLIDE:
				queue_free()
