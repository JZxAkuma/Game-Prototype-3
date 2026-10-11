extends PanelContainer

@onready var model_holder: Node3D = $VBoxContainer/SubViewportContainer/SubViewport/ModelHolder
@onready var name_label: Label = $VBoxContainer/NameLabel
@onready var slot_label: Label = $VBoxContainer/SlotLabel

func _setup(slot: int, data: CharacterData) -> void:
	slot_label.text = "P%d" % (slot + 1)
	name_label.text = data.display_name
	model_holder.add_child(data.model_scene.instantiate())
