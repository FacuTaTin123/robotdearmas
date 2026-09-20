extends CharacterBody2D

const Bala = preload("res://Bala.tscn")

var mirando_derecha: bool = true
var disparar_presionada_anteriormente: bool = false

@export var velocidad: float = 300.0
@export var fuerza_salto: float = -550.0
@export var gravedad: float = 1200.0
@export var corte_salto: float = -350.0
@export var costo_municion_por_disparo: int = 1

var vida: int = 100
var recibiendo_daño = false
var saltos_disponibles = 2
var w_presionada_anteriormente = false

var velocidad_caida_maxima: float = 0.0
var daño_caida: int = 20
var estaba_en_el_aire = false

@onready var barra_municion = get_node("../CanvasLayer/BarraMunicion")


func recibir_daño(daño: int):
	vida -= daño
	vida = max(vida, 0)

	print("Vida:", vida)

	get_node("../CanvasLayer/BarraVida").value = vida

	if not recibiendo_daño:
		recibiendo_daño = true
		$Sprite2D.modulate = Color(1, 0.3, 0.3)

		await get_tree().create_timer(0.15).timeout

		$Sprite2D.modulate = Color.WHITE
		recibiendo_daño = false

	if vida <= 0:
		morir()


func morir():
	print("Se acabo")
	queue_free()


func _physics_process(delta: float) -> void:

	if not is_on_floor():
		velocity.y += gravedad * delta

		if velocity.y > velocidad_caida_maxima:
			velocidad_caida_maxima = velocity.y

		estaba_en_el_aire = true

	if is_on_floor():
		saltos_disponibles = 2

	var izquierda = Input.is_key_pressed(KEY_A)
	var derecha = Input.is_key_pressed(KEY_D)

	var direccion_x = int(derecha) - int(izquierda)
	velocity.x = direccion_x * velocidad

	if direccion_x < 0:
		$Sprite2D.flip_h = true
		mirando_derecha = false
	elif direccion_x > 0:
		$Sprite2D.flip_h = false
		mirando_derecha = true

	# ANIMACIÓN
	if direccion_x != 0 and is_on_floor():
		$Sprite2D.play("walk")
	else:
		$Sprite2D.play("idle")

	var w_presionada = Input.is_key_pressed(KEY_W)

	if w_presionada and not w_presionada_anteriormente:
		if saltos_disponibles > 0:
			velocity.y = fuerza_salto
			saltos_disponibles -= 1

	if not w_presionada and velocity.y < corte_salto:
		velocity.y = corte_salto

	w_presionada_anteriormente = w_presionada

	var disparar_presionado = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)

	if disparar_presionado and not disparar_presionada_anteriormente:
		disparar()

	disparar_presionada_anteriormente = disparar_presionado

	move_and_slide()

	if is_on_floor() and estaba_en_el_aire:

		if velocidad_caida_maxima > 900:
			recibir_daño(daño_caida)

		estaba_en_el_aire = false
		velocidad_caida_maxima = 0.0


func disparar() -> void:
	if barra_municion.value < costo_municion_por_disparo:
		print("Sin municion")
		return

	barra_municion.value -= costo_municion_por_disparo

	var bala = Bala.instantiate()

	bala.global_position = $PuntoDeDisparo.global_position

	var direccion_disparo = (get_global_mouse_position() - $PuntoDeDisparo.global_position).normalized()
	bala.direccion = direccion_disparo

	get_parent().add_child(bala)
