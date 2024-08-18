extends CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.health_changed.connect(update_health_display)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func update_debug_cf(cf: Vector2):
	$constant_force_debug.text = "Path pos : %v" % cf

func update_health_display():
	$health_display.text = "Lives: %d" % Global.player.health
	
func update_shooter_timer(time_left: float):
	$ShooterTimer.text = "Shooter timer %.2f" % time_left
	
func update_chaser_timer(time_left: float):
	$ChaserTimer.text = "Chaser timer %.2f" % time_left

func update_score():
	$Score.text = "Score: %d" % Global.score
