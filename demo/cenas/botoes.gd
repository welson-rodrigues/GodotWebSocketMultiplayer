extends CanvasLayer

func _ready():
	if not OS.has_feature("mobile"):
		hide()
