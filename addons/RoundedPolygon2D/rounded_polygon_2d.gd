@tool
extends Polygon2D
class_name RoundedPolygon2D

@export var corner_radius: float = 0:
	set(v):
		corner_radius = max(v, 0)
		queue_redraw()
@export var corner_detail: int = 8:
	set(v):
		corner_detail = max(v, 0)
		queue_redraw()

var polygon_copy: PackedVector2Array

func _process(delta):
	if polygon.size() >= 3:
		polygons = [null] # Avoids drawing the original polygon
	else:
		polygons.clear()

	if polygon_copy != polygon:
		polygon_copy = polygon
		queue_redraw()

func _draw():
	if corner_radius == 0 or corner_detail == 0:
		draw_polygon(polygon, [color])
		return

	if polygon.size() >= 3:
		_draw_rounded_polygon()

func _draw_rounded_polygon():
	var points: PackedVector2Array

	for i in polygon.size():
		var point: Vector2 = polygon[i]
		var point_before: Vector2 = polygon[i - 1]
		var point_after: Vector2 = polygon[(i + 1) % polygon.size()]
		var direction_b: Vector2 = point.direction_to(point_before)
		var direction_a: Vector2 = point.direction_to(point_after)
		var min_corner_radius: float

		# Locks the anchors in case the distance from the points is smaller
		# than the corner radius
		var distance = min(point.distance_to(point_before), point.distance_to(point_after)) / 2.0
		if distance > corner_radius:
			min_corner_radius = corner_radius
		else:
			min_corner_radius = distance

		var anchor_before: Vector2 = point + direction_b * min_corner_radius
		var anchor_after: Vector2 = point + direction_a * min_corner_radius

		var arc_points: PackedVector2Array
		for j in range(1, corner_detail):
			var arc_point: Vector2 = anchor_before.bezier_interpolate(
				point + direction_b * min_corner_radius / 2.0,
				point + direction_a * min_corner_radius / 2.0,
				anchor_after,
				float(j) / corner_detail
			)
			arc_points.append(arc_point)

		points.append(anchor_before)
		points.append_array(arc_points)
		points.append(anchor_after)

	draw_polygon(points, [color])
