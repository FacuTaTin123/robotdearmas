extends Area2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("jugador"):
		if body.has_method("curar"):
			body.curar(20)
		queue_free()
