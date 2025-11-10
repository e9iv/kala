class_name IslandGenerator extends Node

const WORLD_SIZE: Vector2i = Vector2i(256, 256)

@export var noise: FastNoiseLite

@export var tree_noise: FastNoiseLite

@onready var tml: TileMapLayer = $"../TileMapManager/TileMapLayer2"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	noise.seed = randi()
	generate()
	#place_trees()

func generate() -> void:
	for x in WORLD_SIZE.x:
		for y in WORLD_SIZE.y:
			var n = noise.get_noise_2d(x, y)
			if n < 0.2:
				tml.set_cell(Vector2i(x,y), 2, Vector2i(0, 1))
			elif n > 0.399:
				tml.set_cell(Vector2i(x,y), 2, Vector2i(1, 0))
			elif n < 0.4:
				tml.set_cell(Vector2i(x,y), 2, Vector2i(0, 0))

func place_trees() -> void:
	for x in WORLD_SIZE.x:
		for y in WORLD_SIZE.y:
			var n = tree_noise.get_noise_2d(x,y)
			if n > 0.05:
				tml.set_cell(Vector2i(x,y), 3, Vector2i.ZERO, 1)
