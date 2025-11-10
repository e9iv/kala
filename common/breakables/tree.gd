extends StaticBody2D

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var marker: Marker2D = $Marker2D

const WOOD_SCENE = preload("uid://doodb5wrshrrw")

var health: int = 3

var r = randi_range(1, 5)

func take_damage():
	health -= 1
	print("Tree:", health)
	if health == 0:
		anim.play("timber")
		await anim.animation_finished
		spawn_wood()
		await get_tree().create_timer(1).timeout
		queue_free()

func spawn_wood():
	for times in range(r):
		var wood = WOOD_SCENE.instantiate()
		wood.position = self.position
		add_child(wood)
