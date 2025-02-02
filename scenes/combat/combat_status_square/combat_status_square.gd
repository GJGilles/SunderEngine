extends Panel

class_name CombatStatusSquareController

@onready var title = $Title
@onready var portrait = $Portrait

@onready var health_bar = $HealthBar
@onready var armor_bar = $ArmorBar
@onready var mana_bar = $ManaBar

# Called when the node enters the scene tree for the first time.
func _ready():
	update_health(-50)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func set_values(name: String, image: Texture2D, health: float, armor: float, mana: float):
	title.text = name
	portrait.texture = image
	health_bar.value = health
	armor_bar.value = armor
	mana_bar.value = mana

func update_health(value: float):
	var tween = create_tween()
	tween.tween_property(health_bar, "value", value, 1)
	
func update_armor(value: float):
	var tween = create_tween()
	tween.tween_property(armor_bar, "value", value, 1)
	
func update_mana(value: float):
	var tween = create_tween()
	tween.tween_property(mana_bar, "value", value, 1) 

