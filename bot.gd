extends CharacterBody2D

@export var velocidad: float = 100.0
@export var gravedad: float = 1200.0

var jugador: Node2D = null


func _physics_process(delta: float) -> void:

	# GRAVEDAD
	if not is_on_floor():
		velocity.y += gravedad * delta
	else:
		velocity.y = 0


	# SI NO DETECTÓ AL JUGADOR
	if jugador == null:
		velocity.x = 0
		$AnimatedSprite2D.play("new_animation")

	else:
		# CALCULAR HACIA QUÉ LADO ESTÁ EL JUGADOR
		var direccion_x = sign(jugador.global_position.x - global_position.x)

		# MOVERSE HACIA EL JUGADOR
		velocity.x = direccion_x * velocidad

		# MIRAR HACIA EL JUGADOR
		if direccion_x < 0:
			$AnimatedSprite2D.flip_h = true
		elif direccion_x > 0:
			$AnimatedSprite2D.flip_h = false

		# ANIMACIÓN
		if direccion_x != 0:
			$AnimatedSprite2D.play("default")
		else:
			$AnimatedSprite2D.play("new_animation")


	# MOVER AL BOT
	move_and_slide()


func _on_detector_body_entered(body):
	print("ENTRÓ AL DETECTOR: ", body.name)

	if body.name == "robot_un_brazo":
		jugador = body
		print("JUGADOR DETECTADO")


func _on_detector_body_exited(body):
	print("SALIO DEL DETECTOR: ", body.name)

	if body == jugador:
		jugador = null
		print("JUGADOR FUERA DEL RANGO")
