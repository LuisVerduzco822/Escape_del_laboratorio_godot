extends CharacterBody2D
## Controla al jugador (sprite "Adam" del pack Modern Interiors).
## Movimiento en 4 direcciones + dash (tecla Espacio/Shift, reemplaza
## el salto ya que el juego es top-down) + disparo de proyectil
## (clic izquierdo o tecla J).

const SPEED := 90.0
const DASH_SPEED := 260.0
const DASH_TIME := 0.18
const DASH_COOLDOWN := 0.6
const INVULN_TIME := 1.0

const IDLE_TEX := preload("res://assets/characters/Adam_idle_anim_16x16.png")
const RUN_TEX := preload("res://assets/characters/Adam_run_16x16.png")
const BULLET_SCENE := preload("res://scenes/player/Bullet.tscn")
const SpriteBuilder := preload("res://scripts/util/SpriteBuilder.gd")

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var facing := "down"
var dash_dir := Vector2.ZERO
var dash_timer := 0.0
var dash_cooldown_timer := 0.0
var is_dashing := false
var invuln_timer := 0.0


func _ready() -> void:
	add_to_group("player")
	sprite.sprite_frames = SpriteBuilder.build_four_dir_frames(IDLE_TEX, RUN_TEX)
	sprite.play("idle_down")


func _physics_process(delta: float) -> void:
	if dash_cooldown_timer > 0.0:
		dash_cooldown_timer -= delta
	if invuln_timer > 0.0:
		invuln_timer -= delta

	var input_vec := Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)
	if input_vec.length() > 0.0:
		input_vec = input_vec.normalized()

	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0.0:
			is_dashing = false
	elif Input.is_action_just_pressed("dash") and dash_cooldown_timer <= 0.0 and input_vec.length() > 0.0:
		is_dashing = true
		dash_timer = DASH_TIME
		dash_cooldown_timer = DASH_COOLDOWN
		dash_dir = input_vec
		AudioManager.play_sfx("dash")

	var current_speed := DASH_SPEED if is_dashing else SPEED
	var move_dir := dash_dir if is_dashing else input_vec
	velocity = move_dir * current_speed
	move_and_slide()

	if input_vec.length() > 0.0:
		facing = _dir_from_vector(input_vec)

	_update_animation(input_vec.length() > 0.0 or is_dashing)

	if Input.is_action_just_pressed("shoot"):
		_shoot()


func _dir_from_vector(v: Vector2) -> String:
	if abs(v.x) > abs(v.y):
		return "right" if v.x > 0.0 else "left"
	return "down" if v.y > 0.0 else "up"


func _update_animation(moving: bool) -> void:
	var anim := ("run_" if moving else "idle_") + facing
	if sprite.animation != anim:
		sprite.play(anim)


func _vector_from_dir(d: String) -> Vector2:
	match d:
		"up":
			return Vector2.UP
		"down":
			return Vector2.DOWN
		"left":
			return Vector2.LEFT
		"right":
			return Vector2.RIGHT
	return Vector2.DOWN


func _shoot() -> void:
	var bullet := BULLET_SCENE.instantiate()
	get_parent().add_child(bullet)
	bullet.global_position = global_position
	bullet.direction = _vector_from_dir(facing)
	AudioManager.play_sfx("shoot")


func take_damage(amount: int = 1) -> void:
	if invuln_timer > 0.0:
		return
	invuln_timer = INVULN_TIME
	GameManager.player_hit(amount)
	modulate = Color(1.0, 0.4, 0.4)
	var t := create_tween()
	t.tween_property(self, "modulate", Color(1, 1, 1), 0.3)
