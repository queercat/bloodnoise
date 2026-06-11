extends MarginContainer

@onready var volume_slider = $"SettingsMenu/MenuItem/VolumeSlider"
@onready var back_button = $"Back"
var last_thing

func switch_from(from):
	from.hide()
	self.show()
	last_thing = from

func switch_back():
	last_thing.show()
	self.hide()
	last_thing = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	volume_slider.value = GameManager.volume
	volume_slider.value_changed.connect(handle_volume_change)
	back_button.pressed.connect(switch_back)
	
func handle_volume_change(volume):
	GameManager.volume_changed(volume)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
