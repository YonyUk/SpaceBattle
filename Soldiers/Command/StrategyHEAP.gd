extends Node

class_name StrategyHeapMin

var HEAP = []

func _siftdown(start_pos:int,pos:int) -> void:
	var newitem = HEAP[pos]
	while pos > start_pos:
		var parent_pos = (pos - 1) >> 1
		var parent = HEAP[parent_pos]
		if newitem[0] < parent[0]:
			HEAP[pos] = parent
			pos = parent_pos
			continue
		break
	HEAP[pos] = newitem
	pass

func _siftup(pos:int) -> void:
	var end_pos = HEAP.size()
	var start_pos = pos
	var newitem = HEAP[pos]
	var child_pos = 2*pos + 1
	while child_pos < end_pos:
		var right_pos = child_pos + 1
		if right_pos < end_pos and not HEAP[child_pos][0] < HEAP[right_pos][0]:
			child_pos = right_pos
			pass
		HEAP[pos] = HEAP[child_pos]
		pos = child_pos
		child_pos = 2*pos + 1
		pass
	HEAP[pos] = newitem
	_siftdown(start_pos,pos)
	pass

func Push(ship, weight: float) -> void:
	var is_in = false
	for move in HEAP:
		if ship == move[1]:
			is_in = true
			break
		pass
	if not is_in:
		HEAP.append([weight,ship])
		_siftdown(0,HEAP.size() - 1)
		pass
	pass

func Pop():
	var result = HEAP.pop_back()
	if HEAP.size() > 0:
		var returnitem = HEAP[0]
		HEAP[0] = result
		_siftup(0)
		return returnitem[1]
	return result[1]

func Clear() -> void:
	HEAP.clear()
	pass

func Count() -> int:
	return HEAP.size()

func Peek():
	return HEAP[0]
