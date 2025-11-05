extends Sprite2D

@onready var hammer: Node2D = $"../../Hammer"

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	global_position = get_global_mouse_position()
	
	if hammer.visible:
		frame = 1
	else:
		frame = 0
