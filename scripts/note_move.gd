extends MeshInstance3D

var fired = false

@export var note_number: int
@export var note_source: String
@export var duration_in_seconds: float
@export var offset: Vector3
@export var target_position: Vector3
@export var reset_position: Vector3
var material: ShaderMaterial

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	position += offset
	reset_position = global_position
	GameManager.MidiNote.connect(on_note)
	material = material_override

func reset():
	var t = get_tree().create_tween()
	t.tween_property(self, "position", reset_position, 1)
	await t.finished
	fired = false

func on_note(emitter, note):
	if emitter == note_source and note == note_number and not fired:
		var t = get_tree().root.create_tween()
		var target = target_position if target_position != Vector3.ZERO else position - offset 
		t.tween_property(self, "position", target, duration_in_seconds).set_ease(Tween.EASE_IN)
		fired = true
	if emitter == "%s_reset" % note_source and fired:
		reset()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if material:
		GameManager.feed_material_clock(material)
		GameManager.feed_material_spheres(material)
