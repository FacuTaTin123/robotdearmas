extends CharacterBody2D

@export var velocidad: float = 100.0
@export var gravedad: float = 1200.0

@export var punto_a: Marker2D
@export var punto_b: Marker2D

var objetivo: Marker2D
var direccion = -1

# Control del salto para comprobar obstáculos
var comprobando_obstaculo = false
var posicion_antes_del_salto = 0.0
var velocidad_salto = -450.0

@onready var raycast: RayCast2D = $RayCast2D


func _ready() -> void:
	# Empezar caminando hacia la izquierda
	objetivo = punto_a
	direccion = -1

	$AnimatedSprite2D.flip_h = true
	raycast.target_position.x = -500


func _physics_process(delta: float) -> void:

	if not is_on_floor():
		velocity.y += gravedad * delta
	else:
		velocity.y = 0

	if comprobando_obstaculo:

		# Durante el salto sigue avanzando
		velocity.x = direccion * velocidad

		# Cuando vuelve al suelo
		if is_on_floor() and velocity.y >= 0:

			var distancia_recorrida = abs(global_position.x - posicion_antes_del_salto)

			print("Distancia recorrida durante el salto: ", distancia_recorrida)

			# Si casi no avanzó, era una pared
			if distancia_recorrida < 20:

				print("Es una pared. Cambiando de dirección.")

				direccion *= -1

				if direccion == 1:
					objetivo = punto_b
				else:
					objetivo = punto_a

			else:
				print("Parece ser un escalón. Continúo.")

			# Terminamos la comprobación
			comprobando_obstaculo = false


		# Mover
		move_and_slide()

		# Animación
		$AnimatedSprite2D.play("walk")

		return

	if objetivo == punto_a:
		direccion = -1
	else:
		direccion = 1

	if direccion > 0:
		$AnimatedSprite2D.flip_h = false
		raycast.target_position.x = 500
	else:
		$AnimatedSprite2D.flip_h = true
		raycast.target_position.x = -500

	raycast.force_raycast_update()

	if raycast.is_colliding() and is_on_floor():

		print("Obstáculo detectado: ", raycast.get_collider().name)

		# Guardamos dónde estaba antes del salto
		posicion_antes_del_salto = global_position.x

		# Saltamos
		velocity.y = velocidad_salto

		# Empezamos la comprobación
		comprobando_obstaculo = true

	else:

		velocity.x = direccion * velocidad

	$AnimatedSprite2D.play("walk")

	move_and_slide()

	if not comprobando_obstaculo:

		if abs(global_position.x - objetivo.global_position.x) < 10:

			if objetivo == punto_a:
				objetivo = punto_b
			else:
				objetivo = punto_a
