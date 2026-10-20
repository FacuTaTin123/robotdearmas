extends CanvasLayer

@onready var barra_vida = $BarraVida
@onready var texto_vida = $BarraVida/Label

@onready var barra_municion = $BarraMunicion
@onready var texto_municion = $BarraMunicion/Label
@onready var barra_vida_jefe = $BarraVidaJefe
@onready var mira = $Mira

@onready var corazones = [$Corazon1, $Corazon2, $Corazon3]

@export var textura_corazon_lleno: Texture2D
@export var textura_corazon_apagado: Texture2D


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	actualizar_corazones()


func _process(_delta):
	texto_vida.text = str(int(barra_vida.value))
	texto_municion.text = str(int(barra_municion.value))

	mira.position = get_viewport().get_mouse_position()


func actualizar_corazones() -> void:
	for i in range(corazones.size()):
		if i < Progreso.vidas:
			corazones[i].texture = textura_corazon_lleno
		else:
			corazones[i].texture = textura_corazon_apagado
