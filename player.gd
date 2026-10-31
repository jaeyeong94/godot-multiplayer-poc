extends CharacterBody2D

const SPEED := 300.0

const COLOR_HOST := Color(0.2, 0.6, 1.0)     # blue
const COLOR_CLIENT := Color(0.2, 0.9, 0.4)   # green
const COLOR_REMOTE := Color(1.0, 0.5, 0.1)   # orange

@onready var box: ColorRect = $ColorRect


func _enter_tree() -> void:
	# MultiplayerSpawner names each spawned player after its peer id.
	set_multiplayer_authority(name.to_int())


func _ready() -> void:
	if is_multiplayer_authority():
		box.color = COLOR_HOST if multiplayer.get_unique_id() == 1 else COLOR_CLIENT
	else:
		box.color = COLOR_REMOTE


func _physics_process(_delta: float) -> void:
	if is_multiplayer_authority():
		var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		velocity = direction * SPEED
		move_and_slide()
