@tool
## A 2D polygon with rounded corners.
extends Polygon2D
class_name RoundedPolygon2D

## Sets the corner radius of all vertices of the polygon.
@export_range(0, 1, 1, "or_greater", "suffix:px") var corner_radius: int = 0:
	set(v):
		corner_radius = v
		queue_redraw()

## Sets the number of divisions each corner has.
@export_range(0, 20, 1) var corner_detail: int = 8:
	set(v):
		corner_detail = v
		queue_redraw()

## If [code]true[/code], makes both sides of the rounded corners the same width if one of the sides
## is capped when the corner radius is bigger than the space available, making it more
## circular at high radius values.
@export var uniform_corners: bool = true:
	set(v):
		uniform_corners = v
		queue_redraw()


## The computed polygon with rounded corners.
var rounded_polygon: PackedVector2Array

var _polygon_copy: PackedVector2Array

func _process(delta):
	# Disables rendering the default Polygon2D
	polygons = [null]

	if _polygon_copy != polygon:
		_polygon_copy = polygon
		queue_redraw()

func _draw():
	if polygon.size() < 3:
		return

	if not corner_radius or not corner_detail:
		draw_polygon(polygon, [color])
		return


	polygons = [null]

	rounded_polygon = _build_rounded_polygon()
	#draw_polyline(rounded_polygon, Color.RED)
	draw_polygon(rounded_polygon, [color])
#
func _build_rounded_polygon() -> PackedVector2Array:
	var points: PackedVector2Array

	for i in polygon.size():
		var point: Vector2 = polygon[i]
		var point_before: Vector2 = polygon[i - 1]
		var point_after: Vector2 = polygon[(i + 1) % polygon.size()]
		var direction_b: Vector2 = point.direction_to(point_before)
		var direction_a: Vector2 = point.direction_to(point_after)
		var distance_a: float = corner_radius
		var distance_b: float = corner_radius

		# Locks the anchors in case the middle point between the points is smaller
		# than the corner radius
		if uniform_corners:
			var mid_point = min(point.distance_to(point_before), point.distance_to(point_after)) / 2.0
			if corner_radius > mid_point:
				distance_a = mid_point
				distance_b = mid_point
		else:
			var mid_point_b = point.distance_to(point_before) / 2.0
			if corner_radius > mid_point_b:
				distance_b = mid_point_b

			var mid_point_a = point.distance_to(point_after) / 2.0
			if corner_radius > mid_point_a:
				distance_a = mid_point_a

		var anchor_before: Vector2 = point + direction_b * distance_b
		var anchor_after: Vector2 = point + direction_a * distance_a

		# Build arc
		var arc_points: PackedVector2Array
		for j in range(1, corner_detail):
			var arc_point: Vector2 = anchor_before.bezier_interpolate(
				point + direction_b * distance_b / 2.0,
				point + direction_a * distance_a / 2.0,
				anchor_after,
				float(j) / corner_detail
			)
			arc_points.append(arc_point)

		points.append(anchor_before)
		points.append_array(arc_points)
		points.append(anchor_after)
	return points
