extends Area2D

@export var velocidad: float = 400.0
@export var tiempo_de_vida: float = 3.0
@export var daño: int = 10

var direccion: Vector2 = Vector2.LEFT

func _ready() -> void:
	rotation = direccion.angle()
	body_entered.connect(_on_body_entered)
	await get_tree().create_timer(tiempo_de_vida).timeout
	queue_free()

func _physics_process(delta: float) -> void:
	position += direccion * velocidad * delta

func _on_body_entered(body: Node2D) -> void:
	if not is_instance_valid(body):
		return

	if body.is_in_group("jugador"):
		if body.has_method("recibir_daño"):
			body.recibir_daño(daño)
		call_deferred("queue_free")
	elif not body.is_in_group("bots"):
		call_deferred("queue_free")
