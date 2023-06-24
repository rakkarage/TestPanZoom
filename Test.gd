extends SubViewport

@onready var _camera: Camera2D = $Camera2D
@onready var _tileMap: TileMap = $TileMap

const _zoomMin := 0.2
const _zoomMinVector := Vector2(_zoomMin, _zoomMin)
const _zoomMax := 16.0
const _zoomMaxVector := Vector2(_zoomMax, _zoomMax)
const _zoomFactor := 0.1
const _zoomFactorVector := Vector2(_zoomFactor, _zoomFactor)

var _panning := false

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			_zoom(event.global_position, _zoomFactorVector)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			_zoom(event.global_position, -_zoomFactorVector)
		elif event.button_index == MOUSE_BUTTON_LEFT:
			_panning = event.pressed
	elif event is InputEventMouseMotion and _panning:
			_pan(event.relative)

func _pan(delta: Vector2) -> void:
	_camera.global_position -= delta / _camera.zoom

func _zoom(position: Vector2, factor: Vector2) -> void:
	printMapMousePosition()
	var z0 := _camera.zoom
	print(z0)
	var z1 = (z0 + factor).clamp(_zoomMinVector, _zoomMaxVector)
	print(z1)
	var c0 := _camera.global_position
	print(c0)
	var c1 = c0 + position * (z0 - z1)
	print(c1)
	_camera.zoom = z1
	_camera.global_position = c1
	printMapMousePosition()

func printMapMousePosition() -> void:
	var mousePosition := _tileMap.to_local(_camera.get_global_mouse_position())
	print(mousePosition)
