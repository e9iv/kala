extends Node2D

const TILE_SIZE: Vector2i = Vector2i(8, 8)
const BUILD_COST: int = 2
const GHOST_MODULATE := Color(1.0, 1.0, 1.0, 0.5)
const VALID_BUILD_COLOR := Color(0.5, 1.0, 0.5, 0.6)
const INVALID_BUILD_COLOR := Color(1.0, 0.5, 0.5, 0.6)

@onready var sprite: Sprite2D = $Sprite2D
@onready var outline: Sprite2D = $Sprite2D/Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var tilemaplayer: TileMapLayer
@export var preview_layer: TileMapLayer  # Separate layer for preview
@export var notification_label: Label  # Label for displaying messages

var rotation_speed := 15.0
var can_build := true
var can_break := true
var is_active := false
var current_preview_cell: Vector2i = Vector2i(-9999, -9999)  # Track current preview position
var notification_timer: float = 0.0
const NOTIFICATION_DURATION: float = 2.0

func _ready() -> void:
	visible = false
	if has_node("BuildModeHUD"):
		$BuildModeHUD.visible = false
	
	# If no preview layer is assigned, create a preview using modulate
	if not preview_layer:
		preview_layer = tilemaplayer

func _process(delta: float) -> void:
	# Update notification timer
	if notification_timer > 0.0:
		notification_timer -= delta
		if notification_timer <= 0.0 and notification_label:
			notification_label.text = ""
	
	var mouse_pos = get_global_mouse_position()
	var target_rotation = (mouse_pos - global_position).angle()
	rotation = lerp_angle(rotation, target_rotation, rotation_speed * delta)

	# Handle sprite flipping
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
	
	# Toggle build mode
	if Input.is_action_just_pressed("build_mode"):
		toggle_build_mode()
	
	if not is_active:
		return
	
	# Show build preview
	update_build_preview()
	
	# Build/destroy actions
	if Input.is_action_just_pressed("lmb"):
		build()
	
	if Input.is_action_just_pressed("rmb"):
		destroy()

func toggle_build_mode() -> void:
	is_active = not is_active
	visible = is_active
	
	if has_node("BuildModeHUD"):
		$BuildModeHUD.visible = is_active
	
	if has_node("../Axe"):
		$"../Axe".visible = not is_active
	
	# Clear preview when exiting build mode
	if not is_active:
		clear_preview()

func clear_preview() -> void:
	if preview_layer and current_preview_cell != Vector2i(-9999, -9999):
		# If using separate layer, erase preview
		if preview_layer != tilemaplayer:
			preview_layer.erase_cell(current_preview_cell)
		current_preview_cell = Vector2i(-9999, -9999)

func show_notification(message: String) -> void:
	if notification_label:
		notification_label.text = message
		notification_timer = NOTIFICATION_DURATION

func update_build_preview() -> void:
	var mouse_pos = get_global_mouse_position()
	var cell = tilemaplayer.local_to_map(tilemaplayer.to_local(mouse_pos))
	
	# Only update if cell changed
	if cell == current_preview_cell:
		return
	
	# Clear old preview
	clear_preview()
	current_preview_cell = cell
	
	# Check if cell is already occupied
	var tile_data = tilemaplayer.get_cell_tile_data(cell)
	var can_place = tile_data == null and InventoryManager.wood >= BUILD_COST
	
	# Draw preview tile
	if preview_layer != tilemaplayer:
		# Use separate preview layer (recommended)
		preview_layer.set_cell(cell, 0, Vector2i(1, 1))  # Use raft tile
		preview_layer.modulate = VALID_BUILD_COLOR if can_place else INVALID_BUILD_COLOR

func build() -> void:
	if not can_build:
		return
	
	# Check if player has enough wood
	if InventoryManager.wood < BUILD_COST:
		show_notification("Not enough wood!")
		return
	
	var mouse_pos = get_global_mouse_position()
	var cell = tilemaplayer.local_to_map(tilemaplayer.to_local(mouse_pos))
	
	# Check if cell is already occupied
	var tile_data = tilemaplayer.get_cell_tile_data(cell)
	if tile_data != null:
		show_notification("Can't build here!")
		return
	
	can_build = false
	tilemaplayer.set_cells_terrain_connect([cell], 0, 0)
	animation_player.play("build_right")
	InventoryManager.wood -= BUILD_COST
	
	await animation_player.animation_finished
	can_build = true

func destroy() -> void:
	if not can_break:
		return
	
	var mouse_pos = get_global_mouse_position()
	var cell = tilemaplayer.local_to_map(tilemaplayer.to_local(mouse_pos))
	
	# Check if there's actually a tile to destroy
	var tile_data = tilemaplayer.get_cell_tile_data(cell)
	if tile_data == null:
		show_notification("Nothing to destroy!")
		return
	
	# Check if it's a destroyable tile (e.g., wooden raft)
	if tile_data.get_custom_data("type") != "wood":
		show_notification("Can't destroy this!")
		return
	
	can_break = false
	InventoryManager.wood += BUILD_COST - 1  # Refund the wood
	tilemaplayer.erase_cell(cell)
	tilemaplayer.set_cells_terrain_connect([cell], 0, -1, false)
	animation_player.play("build_right")  # Or add a destroy animation
	
	await animation_player.animation_finished
	can_break = true
