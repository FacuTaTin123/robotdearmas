extends CanvasLayer

@onready var barra_vida = $BarraVida
@onready var texto_vida = $BarraVida/Label

@onready var barra_municion = $BarraMunicion
@onready var texto_municion = $BarraMunicion/Label

func _process(_delta):
	texto_vida.text = str(int(barra_vida.value))
	texto_municion.text = str(int(barra_municion.value))
