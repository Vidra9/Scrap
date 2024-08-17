extends Area2D

var is_attached_to_player = false
var nodes_leading_to_ship : Array
var other_nodes : Array
var other_to_remove: Array

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	nodes_leading_to_ship = []
	other_nodes = []

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func add_other_node(node):
	if other_nodes.find(node) == -1:
		other_nodes.append(node)

func remove_ship_node(node) -> bool:
	nodes_leading_to_ship.erase(node)
	return nodes_leading_to_ship.size() == 0 #mark debree for deletion

func delete_other_node(node):
	other_nodes.erase(node)

func delete_self_and_other():
	for node in other_nodes:
		Global.debree_list.erase(self)
		node.queue_free()
	queue_free()
	Global.update_num_of_attached_debree.emit()

func delete():
	other_to_remove = []
	if other_nodes.size() > 0:
		for node in other_nodes:
			if node.call("remove_ship_node", self):
				node.delete()
				other_to_remove.append(node)
				
	
	for node in other_to_remove:
		node.call_deferred("delete_self_and_other")
	
	for node in nodes_leading_to_ship:
		if node != Global.player.get_node("PickupArea"):
			node.call("delete_other_node", self)
	
	Global.debree_list.erase(self)
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("ship_parts"):
		if Global.debree_list.find(self) == -1:
			call_deferred("reparent", Global.player)
			Global.debree_list.append(self)
			Global.update_num_of_attached_debree.emit()
			if nodes_leading_to_ship.find(area) == -1:
				nodes_leading_to_ship.append(area) 
			if area != Global.player.get_node("PickupArea"):
				area.call("add_other_node", self)

func _on_mouse_entered() -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		delete()
		
