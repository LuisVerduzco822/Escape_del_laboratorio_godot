extends Area2D
## Moneda flotante recolectable. Al tocar al jugador (body_entered)
## suma al contador de monedas y se elimina de la escena.

@export var value := 1


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	var t := create_tween()
	t.set_loops()
	t.tween_property($Icon, "position:y", -3.0, 0.5).set_trans(Tween.TRANS_SINE)
	t.tween_property($Icon, "position:y", 0.0, 0.5).set_trans(Tween.TRANS_SINE)


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		GameManager.collect_coin(value)
		queue_free()
