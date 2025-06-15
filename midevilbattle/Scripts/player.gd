class_name Player
extends Character

@onready var enemy_slots : Array = $PrimaryEnemySlots.get_children()

func _ready() -> void:
	super._ready()
	anim_attacks = ["punch", "punch_alt", "punch_alt_2", "punch_alt_3"]

func handle_input() -> void:
	if can_move():
		var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		velocity = direction * speed
	if can_attack() and Input.is_action_just_pressed("attack"):
			if can_pickup_collectible():
				state = State.PICKUP
			else:
				state = State.ATTACK
				if is_last_hit_successful:
					attack_combo_index = (attack_combo_index + 1) % anim_attacks.size()
					is_last_hit_successful = false
				else:
					attack_combo_index = 0
	elif can_attack() and Input.is_action_just_pressed("throw"):
		if has_knife:
			state = State.THROW
	if can_jump() and Input.is_action_just_pressed("jump"):
		state = State.TAKEOFF
	if can_jumpkick() and Input.is_action_just_pressed("throw"):
		if has_knife:
			state = State.JUMPTHROW
	elif can_jumpkick() and Input.is_action_just_pressed("attack"):
			state = State.JUMPKICK
		

func set_heading() -> void:
	if can_move():
		if velocity.x > 0:
			heading = Vector2.RIGHT
		elif velocity.x < 0:
			heading = Vector2.LEFT
		
func reserve_slot(enemy: BasicEnemy) -> EnemySlot:
	var available_slots := enemy_slots.filter(
		func(slot): return slot.is_free()
	)
	if available_slots.size() == 0:
		return null
	available_slots.sort_custom(
		func(a: EnemySlot, b: EnemySlot):
			var dist_a := (enemy.global_position - a.global_position).length()
			var dist_b := (enemy.global_position - b.global_position).length()
			return dist_a < dist_b
	)
	available_slots[0].occupy(enemy)
	return available_slots[0]

func free_slot(enemy: BasicEnemy) -> void:
	var target_slots := enemy_slots.filter(
		func(slot: EnemySlot): return slot.occupant == enemy
	)
	if target_slots.size() == 1:
		target_slots[0].free_up()

func can_get_hurt() -> bool:
	return [State.IDLE, State.WALK, State.TAKEOFF, State.LAND].has(state)

func can_get_hit_thrown(hit_type) -> bool:
	return hit_type == DamageReceiver.HitType.ENEMYTHROWN

func on_throw_complete() -> void:
	var knife_global_position := Vector2(weapon_position_bottom.global_position)
	var knife_height := -(weapon_position_top.global_position.y - weapon_position_bottom.global_position.y)
	state = State.IDLE
	has_knife = false
	EntityManager.spawn_collectible.emit(Collectible.Type.PLAYER_KNIFE, Collectible.State.FLY, knife_global_position, heading, knife_height)

func on_jump_throw_complete():
	var knife_global_position := Vector2(weapon_position_bottom.global_position)
	var knife_height := -(weapon_position_top.global_position.y - weapon_position_bottom.global_position.y)
	state = State.JUMP
	has_knife = false
	EntityManager.spawn_collectible.emit(Collectible.Type.PLAYER_KNIFE, Collectible.State.FLY, knife_global_position, heading, knife_height)
