class_name Tile
extends Panel

const APPEAR_ANIMATION_TIME: float = 0.2
const MERGE_ANIMATION_TIME: float = 0.1
const MOVE_ANIMATION_TIME: float = 0.1

const MERGE_PARTICLES_SCENE: PackedScene = preload("res://scenes/merge_particles.tscn")
const COLOR_MAP: ColorMap = preload("res://resources/color_map.tres")

var position_tween: Tween
@onready var label: Label = $Label

var target_position: Vector2
var value: int = 0: 
	set(new_value):
		value = new_value
		label.text = str(value)
		self_modulate = get_color()

func pop_up(wait_for_move_animation: bool = true) -> void:
	scale = Vector2.ZERO
	self_modulate.a = 0.0

	if wait_for_move_animation:
		get_tree().create_timer(MOVE_ANIMATION_TIME).timeout.connect(play_pop_up_effects)
	else:
		play_pop_up_effects()

func play_pop_up_effects() -> void:
	var tween: Tween = create_tween()
	SoundManager.play_spawn_sound()
	tween.tween_property(self, "scale", Vector2.ONE, APPEAR_ANIMATION_TIME).set_trans(Tween.TRANS_BACK)
	tween.tween_property(self, "self_modulate:a", 1.0, APPEAR_ANIMATION_TIME).set_trans(Tween.TRANS_LINEAR)

func play_merge_effects() -> void:
	spawn_merge_particles()
	SoundManager.play_merge_sound()

	var scale_up: Vector2 = Vector2.ONE * 1.1
	var tween: Tween = create_tween().set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(self, "scale", scale_up, MERGE_ANIMATION_TIME).from(Vector2.ONE)
	tween.tween_property(self, "scale", Vector2.ONE, MERGE_ANIMATION_TIME).from(scale_up)

func update_position(target_cell: Control) -> void:
	var just_appeared: bool = value == 0
	target_position = target_cell.global_position - Vector2(size.x - target_cell.size.x, size.y - target_cell.size.y) * 0.5
	if just_appeared:
		position = target_position
	else:
		if position_tween:
			position_tween.kill()

		position_tween = create_tween()
		position_tween.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
		position_tween.tween_property(self, "position", target_position, MOVE_ANIMATION_TIME)

func spawn_merge_particles() -> void:
	var particles: GPUParticles2D = MERGE_PARTICLES_SCENE.instantiate()
	get_parent().get_parent().add_child(particles)
	particles.self_modulate = self_modulate
	particles.amount = value
	particles.global_position = target_position + pivot_offset
	particles.emitting = true
	particles.finished.connect(particles.queue_free)

func get_color() -> Color:
	return COLOR_MAP.get_color(value)
