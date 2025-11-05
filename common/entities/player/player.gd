extends CharacterBody2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

const SPEED = 50.0

const ACCEL = 250.0
const DECEL = 225.0

enum State { IDLE, RUN }

var current_state := State.IDLE

func _process(delta: float) -> void:
	if get_global_mouse_position().x < global_position.x:
		sprite.flip_h = true
	else:
		sprite.flip_h = false

func _physics_process(delta: float) -> void:
	
	movement(delta)
	update_state()
	handle_animation()
	
	move_and_slide()

func update_state() -> void:
	if abs(velocity.x) > 0:
		current_state = State.RUN
	else:
		current_state = State.IDLE

func handle_animation() -> void:
	match current_state:
		State.IDLE:
			sprite.play("idle")
		State.RUN:
			sprite.play("run")

func movement(delta: float) -> void:
	var dir_x := Input.get_axis("left", "right")
	var dir_y := Input.get_axis("up", "down")
	
	var input_vector := Vector2(dir_x, dir_y).normalized()
	
	# Horizontal movement
	if input_vector.x != 0:
		velocity.x = move_toward(velocity.x, input_vector.x * SPEED, ACCEL * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, DECEL * delta)

	# Vertical movement
	if input_vector.y != 0:
		velocity.y = move_toward(velocity.y, input_vector.y * SPEED, ACCEL * delta)
	else:
		velocity.y = move_toward(velocity.y, 0, DECEL * delta)
