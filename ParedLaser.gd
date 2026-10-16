extends Area2D

@export var tiempo_necesario: float = 1.5
@export var textura_rota: Texture2D
@export_file("*.tscn") var siguiente_escena: String = ""

@onready var fondo: TextureRect = $"../TextureRect"

var tiempo_acumulado: float = 0.0
var rota: bool = false


func _ready() -> void:
	add_to_group("pared_laser")


func recibir_laser(delta: float) -> void:
	if rota:
		return

	tiempo_acumulado += delta

	if tiempo_acumulado >= tiempo_necesario:
		romper()


func romper() -> void:
	if rota:
		return

	rota = true
	fondo.texture = textura_rota

	if siguiente_escena != "":
		await get_tree().create_timer(3.0).timeout
		get_tree().change_scene_to_file(siguiente_escena)
