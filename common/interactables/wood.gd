extends Area2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var is_collected := false
var is_collecting := false

var collection_speed := 300.0
var target_player: CharacterBody2D = null

func _ready() -> void:
	# Add slight random offset to spawn position
	position += Vector2(randf_range(-4, 4), randf_range(-4, 4))

func _process(delta: float) -> void:
	if is_collected and target_player:
		global_position = global_position.move_toward(target_player.global_position, collection_speed * delta)

		if not is_collecting and global_position.distance_to(target_player.global_position) < 5.0:
			is_collecting = true
			collect()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and not is_collected:
		is_collected = true
		target_player = body as CharacterBody2D
		collision_shape.set_deferred("disabled", true)

func collect() -> void:
	InventoryManager.wood += 1
	$WoodSmallGather.play()

	if $WoodSmallGather.has_signal("finished"):
		await $WoodSmallGather.finished

	queue_free()
