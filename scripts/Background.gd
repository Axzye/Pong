extends ScreenObject


@export var factor := 1.0


func update():
	position = (screen_pos - Game.rect.position * factor).round()
