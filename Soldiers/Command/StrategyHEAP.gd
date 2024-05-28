extends Node

class_name StrategyHeapMin

var HEAP = []

func _heap_up(index: int) -> void:
	var father_index = int((index - 1) / 2)
	if index > 0 and HEAP[father_index][0] > HEAP[index][0]:
		var temp = HEAP[index]
		HEAP[index] = HEAP[father_index]
		HEAP[father_index] = temp
		_heap_up(father_index)
		pass
	var left_child_index = index * 2 + 1
	if left_child_index < HEAP.size():
		_heap_down(index)
		pass
	pass

func _heap_down(index:int) -> void:
	var left_child_index = index * 2 + 1
	var right_child_index = left_child_index + 1
	if left_child_index < HEAP.size() and HEAP[left_child_index][0] < HEAP[index][0]:
		var temp = HEAP[left_child_index]
		HEAP[left_child_index] = HEAP[index]
		HEAP[index] = temp
		_heap_down(left_child_index)
		pass
	elif right_child_index < HEAP.size() and HEAP[right_child_index][0] < HEAP[index][0]:
		var temp = HEAP[right_child_index]
		HEAP[right_child_index] = HEAP[index]
		HEAP[index] = temp
		_heap_down(right_child_index)
		pass
	var father_index = int((index - 1) / 2)
	if index > 0 and HEAP[father_index][0] > HEAP[index][0]:
		_heap_up(index)
		pass
	pass

func Push(strategy: GameState, weight: float) -> void:
	var is_in = false
	for move in HEAP:
		if strategy.EqualTo(move[1]):
			is_in = true
			break
		pass
	if not is_in:
		HEAP.append([weight,strategy])
		_heap_up(HEAP.size() - 1)
		pass
	pass

func Pop() -> GameState:
	var result = HEAP[0][1]
	HEAP[0][0] = HEAP[HEAP.size() -1][0] + HEAP[HEAP.size() - 2][0]
	_heap_down(0)
	if HEAP[HEAP.size() - 1][1].EqualTo(result):
		HEAP.pop_at(HEAP.size() - 1)
		pass
	else:
		HEAP.pop_at(HEAP.size() - 2)
		pass
	return result

func Clear() -> void:
	HEAP.clear()
	pass

func Count() -> int:
	return HEAP.size()

func Peek():
	return HEAP[0]
