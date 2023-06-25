extends Node2D

@onready var _camera: Camera2D = $Camera2D

const _zoomMin := 0.2
const _zoomMinVector := Vector2(_zoomMin, _zoomMin)
const _zoomMax := 16.0
const _zoomMaxVector := Vector2(_zoomMax, _zoomMax)
const _zoomFactor := 0.1
const _zoomFactorBase := 10.0

var _panning := false

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			_zoom(event.global_position, _zoomFactor)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			_zoom(event.global_position, -_zoomFactor)
		elif event.button_index == MOUSE_BUTTON_LEFT or event.button_index == MOUSE_BUTTON_MIDDLE:
			_panning = event.pressed
	elif event is InputEventMouseMotion and _panning:
			_pan(event.relative)

func _pan(delta: Vector2) -> void:
	_camera.global_position -= delta / _camera.zoom

func _zoom(at: Vector2, factor: float) -> void:
	var zoomOld := _camera.zoom
	var zoomNew = (zoomOld * pow(_zoomFactorBase, factor)).clamp(_zoomMinVector, _zoomMaxVector)
	_camera.zoom = zoomNew
	var center := _camera.get_viewport().get_visible_rect().size / 2.0
	_camera.global_position += ((at - center) / zoomOld + (center - at) / zoomNew)
