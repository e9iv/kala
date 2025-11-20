extends CharacterBody2D

@export var tml: TileMapLayer

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

@export_group("Movement Variables")
@export_subgroup("Speeds")
@export var speed = 50.0
@export var swim_speed = speed / 2
@export_subgroup("Physics")
@export var accel = 250.0
@export var decel = 225.0

@export_group("Particles")
@export var water_ripple: CPUParticles2D
@export var smoke: CPUParticles2D
@export_group("Footsteps")
@export var sand_sfx: AudioStreamPlayer2D
@export var water_sfx: AudioStreamPlayer2D
@export var wood_sfx: AudioStreamPlayer2D
@export var grass_sfx: AudioStreamPlayer2D

enum State { IDLE, RUN, SWIM, ON_RAFT }

var footsteps_frames: Array = [0, 2, 4, 6]

var current_state := State.IDLE
var current_speed: float = speed

func _process(_delta: float) -> void:
	if get_global_mouse_position().x < global_position.x:
		sprite.flip_h = true
	else:
		sprite.flip_h = false

func _physics_process(delta: float) -> void:
	
	movement(delta)
	update_state()
	handle_animation_and_particles()
	
	move_and_slide()

func update_state() -> void:
	var tile_pos = tml.local_to_map(global_position)
	var tile_data = tml.get_cell_tile_data(tile_pos)
	
	# Check if in water first
	if tile_data and tile_data.get_custom_data("type") == "water":
		current_state = State.SWIM
		current_speed = swim_speed
	elif tile_data and tile_data.get_custom_data("type") == "wood":
		current_state = State.ON_RAFT
		current_speed = speed
		
	# Then check if moving
	elif abs(velocity.x) > 0 or abs(velocity.y) > 0:
		current_state = State.RUN
		current_speed = speed
	# Otherwise idle
	else:
		current_state = State.IDLE
		current_speed = speed

func handle_animation_and_particles() -> void:
	match current_state:
		State.IDLE:
			sprite.play("idle")
			water_ripple.emitting = false
		State.RUN:
			sprite.play("run")
			water_ripple.emitting = false
		State.SWIM:
			sprite.play("swim")
			water_ripple.emitting = true
		State.ON_RAFT:
			water_ripple.emitting = false

func movement(delta: float) -> void:
	var dir_x := Input.get_axis("left", "right")
	var dir_y := Input.get_axis("up", "down")
	
	var input_vector := Vector2(dir_x, dir_y).normalized()
	
	# Horizontal movement
	if input_vector.x != 0:
		velocity.x = move_toward(velocity.x, input_vector.x * current_speed, accel * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, decel * delta)

	# Vertical movement
	if input_vector.y != 0:
		velocity.y = move_toward(velocity.y, input_vector.y * current_speed, accel * delta)
	else:
		velocity.y = move_toward(velocity.y, 0, decel * delta)

func player_walking_on() -> void:
	var tile_pos = tml.local_to_map(tml.to_local(global_position))
	var tile_data = tml.get_cell_tile_data(tile_pos)
	
	match tile_data.get_custom_data("type"):
		"water":
			water_sfx.play()
		"sand":
			sand_sfx.play()
			smoke.emitting = true
		"wood":
			wood_sfx.play()
			smoke.emitting = true
		"grass":
			grass_sfx.play()
			smoke.emitting = true

func _on_sprite_frame_changed() -> void:
	if current_state == State.RUN and sprite.frame in footsteps_frames:
		player_walking_on()
