extends CanvasLayer

var cf_format = "Player constant force : {cf}"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.health_changed.connect(update_health_display)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update_debug_cf(cf: Vector2):
	$constant_force_debug.text = "Player constant force : %v" % Global.player.constant_force

func update_health_display():
	$health_display.text = "Lives: %d" % Global.player.health
	
