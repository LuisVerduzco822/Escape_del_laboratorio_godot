extends Area2D
## Bola de fuego: aparece en el borde derecho de la pantalla y avanza
## en línea recta hacia la izquierda sobre la pasarela metálica. Si el
## jugador la pisa desde arriba (cayendo), se destruye y el jugador
## rebota; si la toca de lado, el jugador pierde.

@export var speed := 120.0

@export var stomp_tolerance := 6.0
@export var despawn_x := -40.0
@export var player_feet_offset := 12.0

var _dead := false


func _ready() -> void:
	add_to_group("enemy")
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	position.x -= speed * delta
	if position.x < despawn_x:
		queue_free()


func _on_body_entered(body: Node) -> void:
	if _dead or not body.is_in_group("player"):
		return
	if body.has_method("die") == false:
		return

	var falling: bool = "velocity" in body and body.velocity.y > 0.0
	var player_feet_y: float = body.global_position.y + player_feet_offset
	var is_above := player_feet_y <= global_position.y + stomp_tolerance

	if falling and is_above:
		_die_stomped(body)
	else:
		body.die()


func _die_stomped(player: Node) -> void:
	_dead = true
	if player.has_method("bounce"):
		player.bounce()
	GameManager.add_score(5)
	AudioManager.play_sfx("hit")
	queue_free()
