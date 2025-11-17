extends StaticBody2D

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var marker: Marker2D = $Marker2D

const WOOD_SCENE = preload("uid://doodb5wrshrrw")

var health: int = 3

func take_damage():
	health -= 1
	print("Tree:", health)
	anim.play("get_hit")
	if health == 0:
		anim.play("timber")
		await anim.animation_finished
		spawn_wood()
		await get_tree().create_timer(1).timeout
		queue_free()

func spawn_wood():
	var r = randi_range(1, 3)
	var spawn_radius = 8.0  # Radius around the tree to spawn wood
	
	for times in r:
		var wood = WOOD_SCENE.instantiate()
		
		# Generate random offset around the tree
		var angle = randf() * TAU  # Random angle in radians (0 to 2π)
		var distance = randf_range(8.0, spawn_radius)  # Random distance from tree
		var offset = Vector2(cos(angle), sin(angle)) * distance
		
		wood.position = self.position + offset
		get_parent().add_child(wood)
