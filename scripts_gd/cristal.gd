extends Area2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("jugador"):
		if body.has_method("activar_brazo"):
			body.activar_brazo()
			$SonidoCristal.play()
			await get_tree().create_timer(0.15).timeout
		queue_free()
