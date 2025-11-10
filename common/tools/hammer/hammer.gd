extends Node2D

const TILE_SIZE: Vector2i = Vector2i(8, 8)

@onready var sprite: Sprite2D = $Sprite2D
@onready var outline: Sprite2D = $Sprite2D/Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var tilemaplayer: TileMapLayer

var rotation_speed := 15.0

var can_build = true
var can_break = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var mouse_pos = get_global_mouse_position()
	var target_rotation = (mouse_pos - global_position).angle()
	rotation = lerp_angle(rotation, target_rotation, rotation_speed * delta)

	if mouse_pos.x < global_position.x:
		sprite.flip_v = true
		outline.flip_v = true
		sprite.position.y = 2
		position.x = 2
	else:
		sprite.flip_v = false
		outline.flip_v = false
		sprite.position.y = 0
		position.x = -2
	
	if Input.is_action_just_pressed("build_mode"):
		if visible:
			visible = false
			$BuildModeHUD.visible = false
		else:
			visible = true
			$BuildModeHUD.visible = true
	
	if Input.is_action_just_pressed("lmb"):
		build()

	if Input.is_action_just_pressed("rmb"):
		destroy()



func build() -> void:
	var mouse_pos = get_global_mouse_position()
	
	if !visible:
		return
	if !can_build:
		return
	else:
		can_build = false
		var cell = tilemaplayer.local_to_map(tilemaplayer.to_local(mouse_pos))
		tilemaplayer.set_cells_terrain_connect([cell], 0, 0)
		animation_player.play("build_right")
		await animation_player.animation_finished
		can_build = true

func destroy() -> void:
	var mouse_pos = get_global_mouse_position()
	
	if !visible:
		return
	if !can_break:
		return
	else:
		can_break = false
		var cell = tilemaplayer.local_to_map(tilemaplayer.to_local(mouse_pos))
		tilemaplayer.erase_cell(cell)
		tilemaplayer.set_cells_terrain_connect([cell], 0, -1, false)
		can_break = true
