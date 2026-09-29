extends Node

@export var escanea_vida: PackedScene = preload("res://computadora.tscn")
@export var tiempo_entre_apariciones: float = 15.0

var puntos_de_spawn: Array[Marker2D] = []

@onready var timer_vida: Timer = $TimerVida

func _ready() -> void:
	puntos_de_spawn = [$"../PuntoVida1", $"../PuntoVida2"]

	timer_vida.wait_time = tiempo_entre_apariciones
	timer_vida.timeout.connect(_on_timer_vida_timeout)
	timer_vida.start()


func _on_timer_vida_timeout() -> void:
	spawnear_vida()

func spawnear_vida() -> void:
	if puntos_de_spawn.is_empty():
		return

	var punto = puntos_de_spawn[randi() % puntos_de_spawn.size()]
	var pickup = escanea_vida.instantiate()

	get_parent().add_child(pickup)
	pickup.global_position = punto.global_position
