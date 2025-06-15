extends Node2D

var prefab_map:= {
	Collectible.Type.KNIFE: preload("res://Screens/Props/knife.tscn"),
	Collectible.Type.ENEMY_KNIFE: preload("res://Screens/Props/knife.tscn"),
	Collectible.Type.PLAYER_KNIFE: preload("res://Screens/Props/knife.tscn")
}
func _ready():
	EntityManager.spawn_collectible.connect(_on_spawn_collectible.bind())
func _on_spawn_collectible(type: Collectible.Type, initial_state: Collectible.State, collectible_global_position: Vector2, collectibel_direction: Vector2, inital_height:float):
	var collectible: Collectible = prefab_map[type].instantiate()
	collectible.state = initial_state
	collectible.height = inital_height
	collectible.global_position = collectible_global_position
	collectible.direction = collectibel_direction
	collectible.type = type
	add_child(collectible)
