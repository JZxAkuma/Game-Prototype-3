extends PanelContainer

@onready var model_holder: Node3D = $VBoxContainer/PanelContainer/SubViewportContainer/SubViewport/ModelHolder
@onready var name_label: Label = $VBoxContainer/NameLabel
@onready var slot_label: Label = $VBoxContainer/SlotLabel

func _setup(slot: int, data: CharacterData) -> void:
	slot_label.text = "P%d" % (slot + 1)
	name_label.text = data.display_name

	var c = data.scene.instantiate()
	model_holder.add_child(c)
	c.setup(slot)
	c.set_mode(c.Mode.LOCKED)
