extends Node2D
## Script compartido por Level1/Level2/Level3.
## Cada nivel tiene un nodo "Items" (estrellas), un nodo "Exit"
## (Area2D con nodos "Visual" y "Label") y un nodo "World" donde viven
## jugador, enemigos y muebles (ordenados por profundidad).
## La salida está cerrada (roja) hasta recolectar todas las estrellas.

@export var level_title := "NIVEL 1 - FACIL"
@export var level_width := 480.0

@onready var exit_visual: ColorRect = get_node_or_null("Exit/Visual")
@onready var exit_label: Label = get_node_or_null("Exit/Label")


func _ready() -> void:
	var player := get_node_or_null("World/Player")
	if player:
		var cam: Camera2D = player.get_node_or_null("Camera2D")
		if cam:
			cam.make_current()
			cam.limit_left = 0
			cam.limit_top = 0
			cam.limit_right = int(level_width)
			cam.limit_bottom = 270

	var items_node := get_node_or_null("Items")
	var total_items := items_node.get_child_count() if items_node else 0
	GameManager.register_level_items(total_items)
	GameManager.item_collected.connect(_on_items_changed)
	_update_exit(total_items)

	var exit_area := get_node_or_null("Exit")
	if exit_area:
		exit_area.body_entered.connect(_on_exit_entered)

	AudioManager.play_music()
	_show_title()


func _on_items_changed(remaining: int) -> void:
	_update_exit(remaining)


func _update_exit(remaining: int) -> void:
	if exit_visual == null:
		return
	if remaining <= 0:
		exit_visual.color = Color(0.3, 0.9, 0.5, 1)
		if exit_label:
			exit_label.text = "SALIDA"
	else:
		exit_visual.color = Color(0.85, 0.25, 0.25, 1)
		if exit_label:
			exit_label.text = "CERRADA"


func _on_exit_entered(body: Node) -> void:
	if body.is_in_group("player") and GameManager.items_remaining <= 0:
		GameManager.level_complete()


func _show_title() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 5
	add_child(layer)
	var label := Label.new()
	label.text = level_title
	label.add_theme_font_size_override("font_size", 14)
	label.add_theme_color_override("font_color", Color(1, 0.9, 0.35))
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0))
	label.add_theme_constant_override("outline_size", 5)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP)
	label.offset_top = 28
	label.offset_left = -220
	label.offset_right = 220
	layer.add_child(label)
	var t := create_tween()
	t.tween_interval(1.6)
	t.tween_property(label, "modulate:a", 0.0, 0.6)
	t.tween_callback(layer.queue_free)
