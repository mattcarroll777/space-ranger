extends Control
## Crosshair — fixed at screen center (industry standard: the world rotates behind
## it, never the other way). Four ticks + a dot; the gap tightens while aiming.

const TICK := 7.0
const GAP_HIP := 14.0
const GAP_AIM := 6.0
const COLOR := Color(1, 1, 1, 0.9)
const SHADOW := Color(0, 0, 0, 0.5)

var _gap := GAP_HIP

func set_aiming(aiming: bool) -> void:
	_gap = GAP_AIM if aiming else GAP_HIP

func _process(_delta: float) -> void:
	queue_redraw()  # window moves/resizes under WSLg can strand a stale frame; always re-center

func _draw() -> void:
	var c := size * 0.5
	for o in [Vector2(1, 1), Vector2.ZERO]:  # cheap drop shadow, then the crosshair
		var col: Color = SHADOW if o == Vector2(1, 1) else COLOR
		draw_circle(c + o, 1.5, col)
		for dir in [Vector2.UP, Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT]:
			draw_line(c + o + dir * _gap, c + o + dir * (_gap + TICK), col, 2.0)
