extends SubViewport

@onready var _camera: Camera2D = $Camera2D

const _zoom_min := 0.2
const _zoom_min_vector := Vector2(_zoom_min, _zoom_min)
const _zoom_max := 16.0
const _zoom_max_vector := Vector2(_zoom_max, _zoom_max)
const _zoom_factor := 0.1
const _zoom_factor_base := 10.0

const _pan_momentum_max := Vector2(100.0, 100.0)
const _pan_momentum_smoothing := 0.9
var _panning := false
var _pan_momentum := Vector2.ZERO

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			_zoom(event.global_position, _zoom_factor)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			_zoom(event.global_position, -_zoom_factor)
		elif event.button_index == MOUSE_BUTTON_LEFT or event.button_index == MOUSE_BUTTON_MIDDLE:
			_panning = event.pressed
	elif event is InputEventMouseMotion and _panning:
		_pan(event.relative)

func _process(_delta: float) -> void:
	if not _panning:
		_camera.global_position -= _pan_momentum / _camera.zoom
		_pan_momentum = _pan_momentum.lerp(Vector2.ZERO, 0.1)

func _pan(delta: Vector2) -> void:
	var new_pan_momentum := _pan_momentum * _pan_momentum_smoothing + delta * (1.0 - _pan_momentum_smoothing)
	_pan_momentum = new_pan_momentum.clamp(-_pan_momentum_max, _pan_momentum_max)
	_camera.global_position -= delta / _camera.zoom

func _zoom(at: Vector2, factor: float) -> void:
	var zoom_old := _camera.zoom
	var zoom_new := (zoom_old * pow(_zoom_factor_base, factor)).clamp(_zoom_min_vector, _zoom_max_vector)
	_camera.zoom = zoom_new
	var center := Vector2(size) / 2.0 # same as: _camera.get_viewport().get_visible_rect().size / 2.0
	_camera.global_position += ((at - center) / zoom_old + (center - at) / zoom_new)
