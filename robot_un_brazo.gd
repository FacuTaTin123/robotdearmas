extends CharacterBody2D

const Bala = preload("res://Bala.tscn")

var mirando_derecha: bool = true
var cooldown_disparo: float = 0.0

@export var velocidad: float = 300.0
@export var fuerza_salto: float = -550.0
@export var gravedad: float = 1200.0
@export var corte_salto: float = -350.0
@export var costo_municion_por_disparo: int = 1
@export var tiempo_entre_disparos: float = 0.2

var vida: int = 100
var recibiendo_daño = false
var saltos_disponibles = 2
var w_presionada_anteriormente = false

var velocidad_caida_maxima: float = 0.0
var daño_caida: int = 20
var estaba_en_el_aire = false
var atravesando_plataforma: bool = false
var tiene_brazo: bool = false
var tiene_laser: bool = false
var cooldown_daño_laser: float = 0.0
var laser_activo: bool = false

@export var daño_laser: int = 20
@export var intervalo_daño_laser: float = 0.1
@export var consumo_laser_por_segundo: float = 15.0
@export var distancia_laser: float = 1400.0
@export var ancho_frame_laser: float = 95.0  # ancho de un frame del sprite sheet

@onready var barra_laser = get_node("../CanvasLayer/BarraLaser")
@onready var barra_municion = get_node("../CanvasLayer/BarraMunicion")
@onready var laser_raycast: RayCast2D = $LaserRayCast
@onready var sprite_laser: AnimatedSprite2D = $SpriteLaser
@onready var chispas_laser: GPUParticles2D = $ChispasLaser

func activar_brazo() -> void:
	tiene_brazo = true
	tiene_laser = true
	barra_laser.visible = true

	Progreso.tiene_brazo = true
	Progreso.tiene_laser = true
	
func _ready() -> void:
	add_to_group("jugador")
	sprite_laser.visible = false
	chispas_laser.emitting = false

	if Progreso.tiene_brazo and Progreso.tiene_laser:
		activar_brazo()

func recibir_daño(daño: int):
	vida -= daño
	vida = max(vida, 0)

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
	get_tree().change_scene_to_file(ProjectSettings.get_setting("application/run/main_scene"))

func curar(cantidad: int) -> void:
	vida += cantidad
	vida = min(vida, 100)

	get_node("../CanvasLayer/BarraVida").value = vida

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

	if not is_on_floor():
		if tiene_brazo:
			$Sprite2D.play("alto robot saltando")
		else:
			$Sprite2D.play("robot saltando")
	elif direccion_x != 0:
		if tiene_brazo:
			$Sprite2D.play("caminando con alto brazo")
		else:
			$Sprite2D.play("walk")
	else:
		if tiene_brazo:
			$Sprite2D.play("quieto con alto brazo")
		else:
			$Sprite2D.play("idle")

	if Input.is_key_pressed(KEY_S) and is_on_floor() and not atravesando_plataforma:
		atravesar_plataforma()

	var w_presionada = Input.is_key_pressed(KEY_W)

	if w_presionada and not w_presionada_anteriormente:
		if saltos_disponibles > 0:
			velocity.y = fuerza_salto
			saltos_disponibles -= 1

	if not w_presionada and velocity.y < corte_salto:
		velocity.y = corte_salto

	w_presionada_anteriormente = w_presionada

	cooldown_disparo -= delta

	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and cooldown_disparo <= 0:
		disparar()
		cooldown_disparo = tiempo_entre_disparos

	if tiene_laser and Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) and barra_laser.value > 0:
		disparar_laser(delta)
	else:
		apagar_laser()

	move_and_slide()

	if is_on_floor() and estaba_en_el_aire:

		if velocidad_caida_maxima > 900:
			recibir_daño(daño_caida)

		estaba_en_el_aire = false
		velocidad_caida_maxima = 0.0

func atravesar_plataforma() -> void:
	atravesando_plataforma = true
	set_collision_mask_value(2, false)

	await get_tree().create_timer(0.3).timeout

	set_collision_mask_value(2, true)
	atravesando_plataforma = false

func disparar_laser(delta: float) -> void:
	if not laser_activo:
		laser_activo = true
	sprite_laser.visible = true

	var origen: Vector2 = $PuntoDeDisparo.global_position
	var direccion_laser = (get_global_mouse_position() - origen).normalized()

	laser_raycast.global_position = origen
	laser_raycast.target_position = direccion_laser * distancia_laser
	laser_raycast.force_raycast_update()

	var punto_final_global: Vector2
	if laser_raycast.is_colliding():
		punto_final_global = laser_raycast.get_collision_point()
	else:
		punto_final_global = origen + direccion_laser * distancia_laser

	# El sprite se estira desde el origen hasta el punto de impacto
	var largo = origen.distance_to(punto_final_global)
	sprite_laser.global_position = origen
	sprite_laser.global_rotation = direccion_laser.angle()
	sprite_laser.scale.x = largo / ancho_frame_laser

	# Chispas en el punto de impacto
	chispas_laser.global_position = punto_final_global
	chispas_laser.emitting = laser_raycast.is_colliding()

	barra_laser.value = max(barra_laser.value - consumo_laser_por_segundo * delta, 0)

	cooldown_daño_laser -= delta

	if laser_raycast.is_colliding():
		var objetivo_laser = laser_raycast.get_collider()

		if is_instance_valid(objetivo_laser):

			if objetivo_laser.is_in_group("bots") and objetivo_laser.has_method("recibir_daño"):
				cooldown_daño_laser -= delta

				if cooldown_daño_laser <= 0:
					objetivo_laser.recibir_daño(daño_laser)
					cooldown_daño_laser = intervalo_daño_laser

			elif objetivo_laser.is_in_group("pared_laser") and objetivo_laser.has_method("recibir_laser"):
				objetivo_laser.recibir_laser(delta)

func apagar_laser() -> void:
	if laser_activo:
		laser_activo = false
	sprite_laser.visible = false
	chispas_laser.emitting = false

func disparar() -> void:
	if barra_municion.value < costo_municion_por_disparo:
		return

	barra_municion.value -= costo_municion_por_disparo

	var bala = Bala.instantiate()

	bala.global_position = $PuntoDeDisparo.global_position

	var direccion_disparo = (get_global_mouse_position() - $PuntoDeDisparo.global_position).normalized()
	bala.direccion = direccion_disparo

	get_parent().add_child(bala)
