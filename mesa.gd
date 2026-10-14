extends Area2D

@onready var sprite = $Sprite2D

var rota: bool = false


func _ready() -> void:
	add_to_group("rompible")
	sprite.play("intacta")


func romper() -> void:
	if rota:
		return

	rota = true
	sprite.play("rota")
