class_name PathfindingNodeHeap extends Resource

var heap:Array = Array()

func insert(added_node:PathfindingNode,priority:int)->void:
	var new_element: PathfindingNodeHeapElement = PathfindingNodeHeapElement.new(added_node,priority)
	heap.append(new_element)
	var index: int = heap.size() -1 #to get index of new_element
	var temporary_element: PathfindingNodeHeapElement
	while index > 0 and heap[(index-1)/2].priority > heap[index].priority: #this should work since dividing int by int should give int as per documentation
		temporary_element = heap[index]
		heap[index] = heap[(index-1)/2]
		heap[(index-1)/2] = temporary_element
		index = (index - 1) / 2
