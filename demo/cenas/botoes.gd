extends CanvasLayer

func _ready():
	# Esconde a interface de botões se não estiver no celular
	# (útil caso queira mostrar só no mobile)
	if not OS.has_feature("mobile"):
		hide()
