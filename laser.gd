extends Area2D

@export var speed := 600.0
@export var impact_scene: PackedScene
var direction := Vector2.RIGHT
var _dead := false

func _ready():
	rotation = direction.angle()
	$VisibleOnScreenNotifier2D.screen_exited.connect(queue_free)
	body_entered.connect(_on_body_entered)

func _physics_process(delta):
	position += direction * speed * delta

func _on_body_entered(body):
	if _dead:
		return
	if body.has_method("take_damage"):
		body.take_damage(1)
	if impact_scene:
		var fx = impact_scene.instantiate()
		fx.global_position = global_position
		get_tree().current_scene.add_child(fx)
	_destroy()

func _destroy():
	_dead = true
	set_physics_process(false)
	$AnimatedSprite2D.hide()
	$CollisionShape2D.set_deferred("disabled", true)
	$GPUParticles2D.emitting = false
	await get_tree().create_timer(0.5).timeout
	queue_free()
