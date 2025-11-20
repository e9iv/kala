extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("switch"):
		if $"../Hammer".visible:
			return
		
		if $Axe.visible:
			$Axe.visible = false
			$Spear.visible = true
		else:
			$Axe.visible = true
			$Spear.visible = false
