class_name ReadyUpCard
extends PanelContainer

@onready var label: Label = $Label

var slot := 0


func setup(p_slot: int) -> void:
	slot = p_slot
	set_ready(false)


func set_ready(is_ready: bool) -> void:
	if is_ready:
		label.text = "P%d\nREADY!" % (slot + 1)
	else:
		label.text = "P%d\nHold LB + RB" % (slot + 1)
