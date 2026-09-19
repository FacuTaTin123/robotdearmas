extends CharacterBody2D

@export var velocidad: float = 300.0
@export var fuerza_salto: float = -550.0
@export var gravedad: float = 1200.0
@export var corte_salto: float = -350.0

var vida: int = 100
var recibiendo_daño = false
var saltos_disponibles = 2
var w_presionada_anteriormente = false

# DAÑO POR CAÍDA
var velocidad_caida_maxima: float = 0.0
var daño_caida: int = 20
var estaba_en_el_aire = false


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

		# Guardamos la caída más fuerte
		if velocity.y > velocidad_caida_maxima:
			velocidad_caida_maxima = velocity.y

		estaba_en_el_aire = true

	# RECARGAR LOS DOS SALTOS
	if is_on_floor():
		saltos_disponibles = 2

	# MOVIMIENTO A / D
	var izquierda = Input.is_key_pressed(KEY_A)
	var derecha = Input.is_key_pressed(KEY_D)

	var direccion_x = int(derecha) - int(izquierda)
	velocity.x = direccion_x * velocidad

	# MIRAR HACIA DONDE CAMINA
	if direccion_x < 0:
		$Sprite2D.flip_h = true
	elif direccion_x > 0:
		$Sprite2D.flip_h = false

	# ANIMACIÓN
	if direccion_x != 0 and is_on_floor():
		$Sprite2D.play("walk")
	else:
		$Sprite2D.play("idle")

	# DETECTAR CUANDO SE APRETA W
	var w_presionada = Input.is_key_pressed(KEY_W)

	if w_presionada and not w_presionada_anteriormente:
		if saltos_disponibles > 0:
			velocity.y = fuerza_salto
			saltos_disponibles -= 1

	# SI SOLTÁS W, CORTA EL SALTO
	if not w_presionada and velocity.y < corte_salto:
		velocity.y = corte_salto

	w_presionada_anteriormente = w_presionada

	# MOVEMOS AL PERSONAJE
	move_and_slide()

	# DETECTAR ATERRIZAJE
	if is_on_floor() and estaba_en_el_aire:

		if velocidad_caida_maxima > 900:
			recibir_daño(daño_caida)

		estaba_en_el_aire = false
		velocidad_caida_maxima = 0.0


func _on_detector_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
