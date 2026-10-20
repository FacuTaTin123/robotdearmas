extends Area2D

@export var velocidad: float = 600.0
@export var tiempo_de_vida: float = 2.0
@export var daño: int = 50

var direccion: Vector2 = Vector2.RIGHT

func _ready() -> void:
	rotation = direccion.angle()
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	await get_tree().create_timer(tiempo_de_vida).timeout
	queue_free()

func _physics_process(delta: float) -> void:
	position += direccion * velocidad * delta

func _on_body_entered(body: Node2D) -> void:
	if not is_instance_valid(body):
		return

	if body.is_in_group("bots"):
		if body.has_method("recibir_daño"):
			body.recibir_daño(daño)
		call_deferred("queue_free")
	elif body.is_in_group("rompible"):
		if body.has_method("romper"):
			body.romper()
		call_deferred("queue_free")
		
func _on_area_entered(area: Area2D) -> void:
	if not is_instance_valid(area):
		return

	if area.is_in_group("rompible"):
		if area.has_method("romper"):
			area.romper()
		call_deferred("queue_free")
