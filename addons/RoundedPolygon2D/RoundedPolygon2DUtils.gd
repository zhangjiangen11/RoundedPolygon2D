extends Object
class_name RoundedPolygon2DUtils

static func v2_to_v3(v2: Vector2):
	return Vector3(v2.x, v2.y, 0)


static func get_2d_triangle_barycentric_coords(_point: Vector2, _a: Vector2, _b: Vector2, _c: Vector2) -> Vector3:
	var point = v2_to_v3(_point)
	var a = v2_to_v3(_a)
	var b = v2_to_v3(_b)
	var c = v2_to_v3(_c)
	return Geometry3D.get_triangle_barycentric_coords(point, a, b, c)

static func mix_colors(colors: PackedColorArray, weights: PackedFloat32Array):
	var color: Color
	if colors.size() != weights.size():
		push_error("Mix colors parameters aren't the same size")
		return Color.BLACK

	for i in range(colors.size()):
		color += colors[i] * weights[i]

	return color
