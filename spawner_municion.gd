extends Node

@export var escena_municion: PackedScene = preload("res://Municion.tscn")
@export var tiempo_entre_apariciones: float = 15.0

var puntos_de_spawn: Array[Marker2D] = []

@onready var timer_municion: Timer = $TimerMunicion

func _ready() -> void:
	puntos_de_spawn = [$"../PuntoMunicion1", $"../PuntoMunicion2"]

	timer_municion.wait_time = tiempo_entre_apariciones
	timer_municion.timeout.connect(_on_timer_municion_timeout)
	timer_municion.start()


func _on_timer_municion_timeout() -> void:
	spawnear_municion()

func spawnear_municion() -> void:
	if puntos_de_spawn.is_empty():
		return

	var punto = puntos_de_spawn[randi() % puntos_de_spawn.size()]
	var pickup = escena_municion.instantiate()

	get_parent().add_child(pickup)
	pickup.global_position = punto.global_position
