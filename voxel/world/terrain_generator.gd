class_name TerrainGenerator
extends Resource

const CHUNK_SIZE = 16
const RANDOM_BLOCK_PROBABILITY = 0.015

const SPAWN_CHANCE = 0.7        # 70% чётных позиций заняты
const BASE_HEIGHT = 5           # желаемая высота колонны в центре (например, 5)
const SLOPE = 0.75               # крутизна подъёма воронки
const MAX_CALC_HEIGHT = 100     # рассчётная максимальная высота (не ограничивает блоки, только логику спавна)
const TOP_BLOCKS = 3            # сколько верхних блоков отображать

static func empty():
	return {}

static func random_blocks():
	var random_data = {}
	for x in range(CHUNK_SIZE):
		for y in range(CHUNK_SIZE):
			for z in range(CHUNK_SIZE):
				var vec = Vector3i(x, y, z)
				if randf() < RANDOM_BLOCK_PROBABILITY:
					random_data[vec] = randi() % 29 + 1
	return random_data

static func flat(chunk_position: Vector3i) -> Dictionary:
	var data = {}
	# Генерируем только чанки на y >= 0 (земля)
	if chunk_position.y < 0:
		return data
	
	for x in range(CHUNK_SIZE):
		for z in range(CHUNK_SIZE):
			if x % 2 == 1 or z % 2 == 1:
				continue
			if randf() > SPAWN_CHANCE:
				continue
			
			var global_x = chunk_position.x * CHUNK_SIZE + x
			var global_z = chunk_position.z * CHUNK_SIZE + z
			var distance = sqrt(global_x*global_x + global_z*global_z)
			var desired_total_height = int(BASE_HEIGHT + SLOPE * distance)
			desired_total_height = max(1, desired_total_height)
			
			# Определяем диапазон y, в котором будут блоки (только верхние TOP_BLOCKS)
			var top_start = max(0, desired_total_height - TOP_BLOCKS)
			var top_end = desired_total_height - 1
			
			var block_y_start = chunk_position.y * CHUNK_SIZE
			var block_y_end = block_y_start + CHUNK_SIZE - 1
			
			var local_y_start = max(block_y_start, top_start)
			var local_y_end = min(block_y_end, top_end)
			if local_y_start > local_y_end:
				continue
			
			var block_type = randi() % 10 + 1
			for y in range(local_y_start - block_y_start, local_y_end - block_y_start + 1):
				var vec = Vector3i(x, y, z)
				data[vec] = block_type
	
	return data

static func get_height_at(world_x: int, world_z: int) -> int:
	# Возвращает высоту вершины колонны (для спавна игрока)
	var distance = sqrt(world_x*world_x + world_z*world_z)
	var height = BASE_HEIGHT + SLOPE * distance
	return int(max(1, height))

static func origin_grass(chunk_position):
	if chunk_position == Vector3i.ZERO:
		return {Vector3i.ZERO: 3}
	return {}
