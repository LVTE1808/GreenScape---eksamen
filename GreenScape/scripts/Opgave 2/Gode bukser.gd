extends Panel




func _on_Gode_bukser_gui_input(event: InputEvent) -> void:
	if event is InputEventScreenDrag:
		rect_position += event.relative



func _on_God_bukser_2_area_entered(area):
	if area.name == "Genbrug":
		Global.Tekstil += 1
		queue_free()
