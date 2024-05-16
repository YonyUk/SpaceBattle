extends Node

class_name HeapMin

var heap := []

func heap_up(index: int) -> void:
	if index > 0:
		var father_index = int((index - 1) / 2)
		if heap[father_index][0] > heap[index][0]:
			var temp = heap[father_index]
			heap[father_index] = heap[index]
			heap[index] = temp
			pass
		heap_down(father_index)
		heap_up(father_index)
		pass
	pass

func heap_down(index: int) -> void:
	var left_child_index = index * 2 + 1
	var right_child_index = index * 2 + 2
	if left_child_index < heap.size():
		if heap[left_child_index][0] < heap[index][0]:
			var temp = heap[index]
			heap[index] = heap[left_child_index]
			heap[left_child_index] = temp
			heap_up(index)
			pass
		pass
	if right_child_index < heap.size():
		if heap[right_child_index][0] < heap[index][0]:
			var temp = heap[index]
			heap[index] = heap[right_child_index]
			heap[right_child_index] = temp
			heap_up(index)
			pass
		pass
	pass

func Contains(pos:Vector2) -> bool:
	for item in heap:
		if item[1] == pos:
			return true
		pass
	return false

func Push(pos:Vector2,weight: float) -> void:
	if not Contains(pos):
		heap.append([weight,pos])
		heap_up(heap.size() - 1)
		pass
	pass

func Pop() -> Vector2:
	var weight = heap[0][0]
	var pos = heap[0][1]
	heap[0][0] = heap[heap.size() - 1][0] + heap[heap.size() - 2][0]
	heap_down(0)
	if heap[heap.size() - 1][1] == pos:
		heap.pop_at(heap.size() - 1)
		pass
	else:
		heap.pop_at(heap.size() - 2)
		pass
	return pos

func Clear() -> void:
	heap.clear()
	pass

func Length() -> int:
	return heap.size()
