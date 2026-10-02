extends Area2D
## Ítem recolectable (estrella, sprite real del pack de assets). Al
## tocar al jugador suma puntos, descuenta del contador de "items
## restantes" del nivel y se destruye a sí mismo.

@export var value := 10


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	# Pequeña animación de flotación para que se note que es
	# interactivo.
	var t := create_tween()
	t.set_loops()
	t.tween_property($Icon, "position:y", -3.0, 0.6).set_trans(Tween.TRANS_SINE)
	t.tween_property($Icon, "position:y", 0.0, 0.6).set_trans(Tween.TRANS_SINE)
	var spin := create_tween()
	spin.set_loops()
	spin.tween_property($Icon/Star, "rotation_degrees", 12.0, 0.4).set_trans(Tween.TRANS_SINE)
	spin.tween_property($Icon/Star, "rotation_degrees", -12.0, 0.4).set_trans(Tween.TRANS_SINE)


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		GameManager.collect_item(value)
		queue_free()
