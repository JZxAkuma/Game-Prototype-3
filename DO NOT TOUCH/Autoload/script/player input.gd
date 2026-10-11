extends Node

signal registration_changed

const max_player := 4
const unassigned := -1
const keyboard := -2

const BASE_ACTIONS: Array[StringName] = [
	&"left", &"right", &"up", &"down",
	&"lb", &"rb", &"a", &"b", &"x", &"y", &"start"
]

var slot_device : Array[int] = [unassigned,unassigned,unassigned,unassigned]

func _act(slot: int,base:StringName) -> StringName:
	return StringName("p%d_%s" % [slot + 1, base])

func _get_move(slot: int) -> Vector2:
	return Input.get_vector(
		_act(slot, &"left"), _act(slot, &"right"),
		_act(slot, &"up"), _act(slot, &"down")
	)

func _registered_count() -> int:
	return max_player - slot_device.count(unassigned)

func _is_slot_registered(slot: int) -> bool:
	return slot_device[slot] != unassigned

func _slot_of_device(device: int) -> int:
	return slot_device.find(device)

# player_input.gd
func _register_joypad(device: int) -> int:
	if _slot_of_device(device) != -1:
		return -1
	var slot := slot_device.find(unassigned)
	if slot == -1:
		return -1
	slot_device[slot] = device
	registration_changed.emit()
	return slot

func _unregister_joypad(device: int) -> void:
	var slot := _slot_of_device(device)
	if slot != -1:
		slot_device[slot] = unassigned
		registration_changed.emit()

func _register_keyboard_for_all() -> void:
	for slot in max_player:
		slot_device[slot] = keyboard
	registration_changed.emit()

func _reset() -> void:
	for slot in max_player:
		slot_device[slot] = unassigned
	registration_changed.emit()

func _build_action() -> void:
	for slot in max_player:
		for base in BASE_ACTIONS:
			var n := _act(slot,base)
			if InputMap.has_action(n):
				InputMap.erase_action(n)
			InputMap.add_action(n,InputMap.action_get_deadzone(base))
			
			var device := slot_device[slot]
			if device == unassigned:
				continue
			
			for ev in InputMap.action_get_events(base):
				var is_pad := ev is InputEventJoypadButton or ev is InputEventJoypadMotion
				if is_pad and device >= 0:
					var copy: InputEvent = ev.duplicate()
					copy.device = device
					InputMap.action_add_event(n,copy)
				elif not is_pad and device == keyboard:
					InputMap.action_add_event(n,ev.duplicate())
