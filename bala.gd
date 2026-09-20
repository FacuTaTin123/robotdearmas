extends Area2D

@export var velocidad: float = 600.0
@export var tiempo_de_vida: float = 2.0
@export var daño: int = 50

var direccion: Vector2 = Vector2.RIGHT

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	await get_tree().create_timer(tiempo_de_vida).timeout
	queue_free()

func _physics_process(delta: float) -> void:
	position += direccion * velocidad * delta

func _on_body_entered(body: Node2D) -> void:
	if is_instance_valid(body) and body.is_in_group("bots"):
		if body.has_method("recibir_daño"):
			body.recibir_daño(daño)
		queue_free()
