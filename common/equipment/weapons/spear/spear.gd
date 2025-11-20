extends Node2D

@onready var sprite := $Sprite2D
@onready var outline := $Sprite2D/Sprite2D

var rotation_speed = 15.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	handle_orientation(delta)

func handle_orientation(delta: float) -> void:
	var mouse_pos = get_global_mouse_position()
	var target_rotation = (mouse_pos - global_position).angle()
	rotation = lerp_angle(rotation, target_rotation, rotation_speed * delta)

	if mouse_pos.x < global_position.x:
		sprite.flip_v = true
		outline.flip_v = true
		sprite.position.y = -4
		position.x = 0
	else:
		sprite.flip_v = false
		outline.flip_v = false
		sprite.position.y = 0
		position.x = 0
