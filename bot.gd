extends CharacterBody2D

signal murio

@export var velocidad: float = 100.0
@export var gravedad: float = 1200.0
@export var vida_maxima: int = 100

@export var punto_a: Marker2D
@export var punto_b: Marker2D

var vida: int = vida_maxima
var muerto: bool = false
var objetivo: Marker2D
var direccion = -1

var comprobando_obstaculo = false
var posicion_antes_del_salto = 0.0
var velocidad_salto = -450.0

@onready var raycast: RayCast2D = $RayCast2D


func _ready() -> void:
	add_to_group("bots")

	objetivo = punto_a
	direccion = -1

	$AnimatedSprite2D.flip_h = true
	raycast.target_position.x = -500


func recibir_daño(daño: int) -> void:
	if muerto:
		return

	vida -= daño
	vida = max(vida, 0)

	print("Vida del bot: ", vida)

	if vida <= 0:
		morir()


func morir() -> void:
	if muerto:
		return

	muerto = true
	murio.emit()
	queue_free()

func _physics_process(delta: float) -> void:

	if muerto:
		return

	if not is_instance_valid(objetivo):
		return

	if not is_on_floor():
		velocity.y += gravedad * delta
	else:
		velocity.y = 0

	if comprobando_obstaculo:

		velocity.x = direccion * velocidad

		if is_on_floor() and velocity.y >= 0:

			var distancia_recorrida = abs(global_position.x - posicion_antes_del_salto)

			if distancia_recorrida < 20:
				direccion *= -1

				if direccion == 1:
					objetivo = punto_b
				else:
					objetivo = punto_a

			comprobando_obstaculo = false

		move_and_slide()

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

		print("he podido detectar ", raycast.get_collider().name)

		posicion_antes_del_salto = global_position.x

		velocity.y = velocidad_salto

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
