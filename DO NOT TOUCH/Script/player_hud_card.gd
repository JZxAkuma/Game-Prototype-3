class_name PlayerHudCard
extends PanelContainer

@onready var name_label: Label = $"HBoxContainer/name label"
@onready var coins_label: Label = $"HBoxContainer/coins label"
@onready var medals_label: Label = $"HBoxContainer/medal label"

var slot := 0


func setup(p) -> void:
	slot = p.slot
	name_label.text = "P%d" % (p.slot + 1)
	refresh(p)

func refresh(p) -> void:
	coins_label.text = str(p.coins)
	medals_label.text = str(p.medal)
