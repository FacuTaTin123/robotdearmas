extends StaticBody2D

@onready var sprite = $AnimatedSprite2D
@onready var colision1 = $CollisionShape2D
@onready var colision2 = $CollisionShape2D2

var rota: bool = false


func _ready() -> void:
	add_to_group("rompible")
	sprite.play("intacta")


func romper() -> void:
	if rota:
		return

	rota = true
	sprite.play("rota")

	colision1.set_deferred("disabled", true)
	colision2.set_deferred("disabled", true)
