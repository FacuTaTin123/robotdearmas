extends Node

@export var escena_bot: PackedScene = preload("res://bot.tscn")
@export var puntos_de_spawn: Array[Marker2D] = []
@export var punto_patrulla_a: Marker2D
@export var punto_patrulla_b: Marker2D
@export var tiempo_entre_apariciones: float = 5.0
@export var bots_para_ganar: int = 10

var bots_eliminados: int = 0
var juego_terminado: bool = false

@onready var timer_spawn: Timer = $TimerSpawn

func _ready() -> void:
	puntos_de_spawn = [$"../SpawnPoint1", $"../SpawnPoint2", $"../SpawnPoint3"]

	timer_spawn.wait_time = tiempo_entre_apariciones
	timer_spawn.timeout.connect(_on_timer_spawn_timeout)
	timer_spawn.start()
	spawnear_bot()

func _on_timer_spawn_timeout() -> void:
	if juego_terminado:
		return
	spawnear_bot()

func spawnear_bot() -> void:
	if puntos_de_spawn.is_empty():
		return

	var punto = puntos_de_spawn[randi() % puntos_de_spawn.size()]
	var bot = escena_bot.instantiate()

	bot.global_position = punto.global_position
	bot.punto_a = punto_patrulla_a
	bot.punto_b = punto_patrulla_b

	bot.murio.connect(_on_bot_murio)

	get_parent().add_child.call_deferred(bot)

func _on_bot_murio() -> void:
	bots_eliminados += 1
	print("Bots eliminados: ", bots_eliminados, "/", bots_para_ganar)

	if bots_eliminados >= bots_para_ganar:
		juego_terminado = true
		timer_spawn.stop()
		print("GANASTE")
