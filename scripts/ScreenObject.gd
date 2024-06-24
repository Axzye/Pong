class_name ScreenObject
extends Node2D


@export var size: Vector2

var screen_pos: Vector2


func _ready():
	get_parent().update_pos.connect(update)


func update():
	position = (screen_pos - Game.rect.position).round()
