extends Node

@onready var _camera: Camera2D = $Camera2D

@export_group("Zoom")
@export var _zoom_min := 0.2
@export var _zoom_max := 16.0
@export var _zoom_factor := 0.1
@export var _zoom_factor_base := 10.0
@export_group("Pan")
@export var _pan_momentum_max := Vector2(100.0, 100.0)
@export var _pan_momentum_threshold := 7.0
@export var _pan_momentum_decay := 0.07
@export var _pan_momentum_smoothing := 0.9
@export var _pan_momentum_reset := 0.1
var _panning := false
var _pan_momentum := Vector2.ZERO
var _pan_momentum_timer := Timer.new()

func _ready() -> void:
	add_child(_pan_momentum_timer)
	_pan_momentum_timer.wait_time = _pan_momentum_reset
	_pan_momentum_timer.one_shot = true
	_pan_momentum_timer.connect("timeout", func(): _pan_momentum = Vector2.ZERO)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			_zoom(event.global_position, _zoom_factor)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			_zoom(event.global_position, -_zoom_factor)
		elif event.button_index == MOUSE_BUTTON_LEFT or event.button_index == MOUSE_BUTTON_MIDDLE:
			_panning = event.pressed
			if not _panning:
				_pan_momentum_timer.stop()
	elif event is InputEventMouseMotion and _panning:
		_pan(event.relative)
		_pan_momentum_timer.start()

func _process(_delta: float) -> void:
	if not _panning:
		if _pan_momentum.length() > _pan_momentum_threshold:
			_camera.global_position -= _pan_momentum / _camera.zoom
	_pan_momentum = _pan_momentum.lerp(Vector2.ZERO, _pan_momentum_decay)

func _pan(delta: Vector2) -> void:
	var new_pan_momentum := _pan_momentum * _pan_momentum_smoothing + delta * (1.0 - _pan_momentum_smoothing)
	_pan_momentum = new_pan_momentum.clamp(-_pan_momentum_max, _pan_momentum_max)
	_camera.global_position -= delta / _camera.zoom

func _zoom(at: Vector2, factor: float) -> void:
	var zoom_old := _camera.zoom
	var zoom_new := (zoom_old * pow(_zoom_factor_base, factor)).clamp(Vector2(_zoom_min, _zoom_min), Vector2(_zoom_max, _zoom_max))
	_camera.zoom = zoom_new
	var center := _camera.get_viewport().get_visible_rect().size / 2.0
	_camera.global_position += ((at - center) / zoom_old + (center - at) / zoom_new)
