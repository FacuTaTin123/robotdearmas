extends Area2D

@export var velocidad_vuelo: float = 600.0
@export var duracion_vuelo: float = 3.0
@export_file("*.tscn") var escena_final: String = ""

@onready var texto: Label = $Label

var jugador_cerca: Node2D = null
var despegando: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("jugador"):
		jugador_cerca = body
		texto.visible = true


func _on_body_exited(body: Node2D) -> void:
	if body == jugador_cerca:
		jugador_cerca = null
		texto.visible = false


func _process(_delta: float) -> void:
	if despegando or jugador_cerca == null:
		return

	if Input.is_key_pressed(KEY_E):
		embarcar()


func embarcar() -> void:
	despegando = true
	texto.visible = false

	jugador_cerca.visible = false
	jugador_cerca.set_physics_process(false)
	jugador_cerca.set_process(false)

	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(self, "position", position + Vector2(2000, -800), duracion_vuelo)
	
	await tween.finished

	#if escena_final != "":
	#	get_tree().change_scene_to_file(escena_final)
