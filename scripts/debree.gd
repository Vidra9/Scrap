extends Area2D

@export var partData: Resource

var is_attached_to_player = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func extra(node):
	partData.set_other_connection(node)

func delete():
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("ship_parts"):
		reparent(Global.player)
		Global.debree_list.append(self)
		partData.set_node_leading_to_ship(area) 
		if area != Global.player.get_node("PickupArea"):
			area.call("extra", self)


func _on_mouse_entered() -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if partData.get_other_connection() != null:
			partData.get_other_connection().call("delete")
		queue_free()
