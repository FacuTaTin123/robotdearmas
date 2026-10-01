extends CanvasLayer

@onready var barra_vida = $BarraVida
@onready var texto_vida = $BarraVida/Label

@onready var barra_municion = $BarraMunicion
@onready var texto_municion = $BarraMunicion/Label
@onready var barra_vida_jefe = $BarraVidaJefe
@onready var mira = $Mira

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN


func _process(_delta):
	texto_vida.text = str(int(barra_vida.value))
	texto_municion.text = str(int(barra_municion.value))

	mira.position = get_viewport().get_mouse_position()
