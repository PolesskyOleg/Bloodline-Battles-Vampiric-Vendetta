class_name PointRandomizer
extends Node2D

enum Priorities {TOP, BOTTOM, LEFT, RIGHT}
	

@onready var navigation_agent : NavigationAgent2D = $NavigationAgent2D
var player_position = Vector2(0, 0) # Предположим, что это позиция игрока

# Функция для получения случайной точки между x и y, с добавлением вектора offset
func get_random_point_with_offset(x: Vector2, y: Vector2, offset: Vector2 = Vector2.ZERO) -> Vector2:
	var random_point = Vector2(randf_range(x.x, y.x), randf_range(x.y, y.y))
	return random_point + offset

# Функция для нахождения ближайшей точки к заданной с использованием navigation agent
func find_nearest_point_in_navigation(point: Vector2, from_point: Vector2) -> Vector2:
	global_position = from_point
	navigation_agent.target_position = point
	return navigation_agent.get_final_position()

# Функция для проверки дистанции от точки до позиции игрока
func is_within_spawn_distance(point: Vector2, player_pos: Vector2, min_distance: float, max_distance: float) -> bool:
	var distance_to_player = point.distance_to(player_pos)
	return distance_to_player > min_distance and distance_to_player < max_distance

# Функция для проверки, находится ли точка внутри прямоугольника, заданного центральной позицией и размерами
func is_point_inside_rect(point: Vector2, center_position: Vector2, rect_size: Vector2) -> bool:
	var rect_position = center_position - rect_size / 2
	var rect = Rect2(rect_position, rect_size)
	return rect.has_point(point)

func generate_point_for_spawn(priorities: Array) -> Array:
	var vps = get_viewport_rect().size
	
	var min_spawn_distance = vps.x / 2  # Минимальная дистанция спавна мобов
	var max_spawn_distance = vps.x      # Максимальная дистанция спавна мобов
	
	for side in priorities:
		var first_point: Vector2
		var second_point: Vector2
		var offset: Vector2
		
		match side:
			Priorities.LEFT:
				first_point = Vector2(0, vps.y / 2) + player_position
				second_point = Vector2(0, -vps.y / 2) + player_position
				offset = (Vector2(-min_spawn_distance, 0) + Vector2(-max_spawn_distance, 0)) / 2
			Priorities.RIGHT:
				first_point = Vector2(0, vps.y / 2) + player_position
				second_point = Vector2(0, -vps.y / 2) + player_position
				offset = (Vector2(min_spawn_distance, 0) + Vector2(max_spawn_distance, 0)) / 2
			Priorities.TOP:
				first_point = Vector2(-vps.x / 2, 0) + player_position
				second_point = Vector2(vps.x / 2, 0) + player_position
				offset = (Vector2(0, -min_spawn_distance) + Vector2(0, -max_spawn_distance)) / 2
			Priorities.BOTTOM:
				first_point = Vector2(-vps.x / 2, 0) + player_position
				second_point = Vector2(vps.x / 2, 0) + player_position
				offset = (Vector2(0, min_spawn_distance) + Vector2(0, max_spawn_distance)) / 2
			_:
				continue

		# Средняя точка между first_point и second_point
		var mid_point = (first_point + second_point) / 2
		
		# Средняя точка с учетом offset
		var offset_point = mid_point + offset
		
		return [offset_point, side]
	
	return [Vector2.ZERO, 0]

# Основная функция, которая выполняет все шаги
func generate_random_point_for_spawn(priorities: Array) -> Vector2:
	var vps = get_viewport_rect().size
	
	var min_spawn_distance = vps.x / 2  # Минимальная дистанция спавна мобов
	var max_spawn_distance = vps.x      # Максимальная дистанция спавна мобов
	
	for side in priorities:
		var first_point: Vector2
		var second_point: Vector2
		var offset: Vector2
		
		match side:
			Priorities.LEFT:
				first_point = Vector2(0, vps.y / 2) + player_position
				second_point = Vector2(0, -vps.y / 2) + player_position
				offset = get_random_point_with_offset(Vector2(-min_spawn_distance, 0), Vector2(-max_spawn_distance, 0))
			Priorities.RIGHT:
				first_point = Vector2(0, vps.y / 2) + player_position
				second_point = Vector2(0, -vps.y / 2) + player_position
				offset = get_random_point_with_offset(Vector2(min_spawn_distance, 0), Vector2(max_spawn_distance, 0))
			Priorities.TOP:
				first_point = Vector2(-vps.x / 2, 0) + player_position
				second_point = Vector2(vps.x / 2, 0) + player_position
				offset = get_random_point_with_offset(Vector2(0, -min_spawn_distance), Vector2(0, -max_spawn_distance))
			Priorities.BOTTOM:
				first_point = Vector2(-vps.x / 2, 0) + player_position
				second_point = Vector2(vps.x / 2, 0) + player_position
				offset = get_random_point_with_offset(Vector2(0, min_spawn_distance), Vector2(0, max_spawn_distance))
			_:
				continue

		var random_point = get_random_point_with_offset(first_point, second_point, offset)
		var double_offset_point = get_random_point_with_offset(first_point, second_point, 2 * offset)
		var nearest_point = find_nearest_point_in_navigation(random_point, double_offset_point)
		
		if not is_point_inside_rect(nearest_point, player_position, vps):
			return nearest_point
	
	return Vector2.ZERO

# Пример использования
func _init():
	Global.point_randomizer = self
	
	
func _process(delta):
	player_position = Global.player.body.global_position
