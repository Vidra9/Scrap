extends Resource

@export var node_leading_to_ship : Resource
@export var other_connection : Resource

func _init(p_node_leading_to_ship = null, p_other_connection = null):
	node_leading_to_ship = p_node_leading_to_ship
	other_connection = p_other_connection

func set_node_leading_to_ship(node):
	node_leading_to_ship = node

func set_other_connection(node):
	other_connection = node

func get_other_connection():
	return other_connection
