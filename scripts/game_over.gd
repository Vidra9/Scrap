extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.game_over.connect(game_over)

func _process(delta: float) -> void:
	if visible and not $AudioStreamPlayer2D.playing:
		$AudioStreamPlayer2D.play()

func game_over():
	$Score.text = "Score: %d" % Global.score

func _on_try_again_pressed() -> void:
	Global.start_game.emit()

func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_visibility_changed() -> void:
	$AudioStreamPlayer2D.seek(0)
	if not visible and $AudioStreamPlayer2D.playing:
		$AudioStreamPlayer2D.stop()
