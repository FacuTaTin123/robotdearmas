extends CharacterBody2D

signal murio

const ArmaDeAvion = preload("res://ArmaDeAvion.tscn")

@export var velocidad: float = 150.0
@export var punto_a: Marker2D
@export var punto_b: Marker2D
@export var distancia_disparo: float = 100000
@export var tiempo_entre_disparos: float = 0.6
@export var vida_maxima: int = 2000

var objetivo: Marker2D
var direccion: int = -1
var cooldown_disparo: float = 0.0
var vida: int = vida_maxima
var muerto: bool = false

@onready var barra_vida_jefe = get_node("../CanvasLayer/BarraVidaJefe")

func _ready() -> void:
	add_to_group("bots")
	objetivo = punto_a

	barra_vida_jefe.max_value = vida_maxima
	barra_vida_jefe.value = vida
	barra_vida_jefe.visible = true


func recibir_daño(daño: int) -> void:
	if muerto:
		return

	vida -= daño
	vida = max(vida, 0)
	barra_vida_jefe.value = vida

	if vida <= 0:
		morir()


func morir() -> void:
	if muerto:
		return

	muerto = true
	barra_vida_jefe.visible = false
	murio.emit()
	call_deferred("queue_free")

func _physics_process(delta: float) -> void:
	if muerto:
		return

	intentar_disparar(delta)

	if objetivo == punto_a:
		direccion = -1
	else:
		direccion = 1

	$Sprite2D.flip_h = direccion > 0

	velocity = Vector2(direccion * velocidad, 0)
	move_and_slide()

	if abs(global_position.x - objetivo.global_position.x) < 10:
		if objetivo == punto_a:
			objetivo = punto_b
		else:
			objetivo = punto_a


func intentar_disparar(delta: float) -> void:
	cooldown_disparo -= delta
	if cooldown_disparo > 0:
		return

	var jugador = get_tree().get_first_node_in_group("jugador")
	if jugador == null:
		return

	var forma_jugador = jugador.get_node_or_null("CollisionShape2D")
	if forma_jugador == null:
		return

	var destino: Vector2 = forma_jugador.global_position
	var origen: Vector2 = global_position

	if origen.distance_to(destino) > distancia_disparo:
		return

	cooldown_disparo = tiempo_entre_disparos

	var bala = ArmaDeAvion.instantiate()
	bala.direccion = (destino - origen).normalized()
	get_parent().add_child(bala)
	bala.global_position = origen
