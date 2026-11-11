extends RefCounted

static func offset(yaw: float, pitch: float, distance: float) -> Vector3:
	return Vector3(sin(yaw) * cos(pitch), sin(pitch), cos(yaw) * cos(pitch)) * distance

static func zoom_weight(delta: float, motion: bool) -> float:
	return 1.0 - exp(-18.0 * delta) if motion else 1.0

static func ground_anchor(camera: Camera3D, screen: Vector2, elevation: float = 0.0) -> Variant:
	var origin := camera.project_ray_origin(screen)
	var direction := camera.project_ray_normal(screen)
	return Plane(Vector3.UP, elevation).intersects_ray(origin, direction)

static func anchored_pivot(pivot: Vector3, anchor: Variant, ratio: float) -> Vector3:
	if not anchor is Vector3: return pivot
	var shift: Vector3 = (anchor - pivot) * (1.0 - ratio)
	shift.y = 0.0
	return pivot + shift
