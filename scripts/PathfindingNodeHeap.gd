class_name PathfindingNodeHeap extends Resource

var heap:Array = Array()

func insert(added_node:PathfindingNode,priority:float)->void:
	var new_element: PathfindingNodeHeapElement = PathfindingNodeHeapElement.new(added_node,priority)
	heap.append(new_element)
	var index: int = heap.size() -1 
	var temporary_element: PathfindingNodeHeapElement	#only used to switch 2 elements with each other, no native implementation exists afaik 
	while index > 0 and heap[(index-1)/2].priority > heap[index].priority: #this should work since dividing int by int should give int as per documentation
		temporary_element = heap[index]
		heap[index] = heap[(index-1)/2]
		heap[(index-1)/2] = temporary_element
		index = (index - 1) / 2
		
		
		#this is a modification of heapify + delete some value, we shouldn't need more,
		#but THINK about possibly implementing both of these funcs
func pop_min() -> PathfindingNode: 
	var output: PathfindingNode 
	output = heap[0].pathfinding_node
	#print(heap[0].priority)
	heap[0] = heap[-1]
	heap.pop_back()
	var left_index:int 
	var right_index:int 
	var smallest: int 
	var index: int = 0
	var temporary_element: PathfindingNodeHeapElement #only used to switch 2 elements with each other, no native implementation exists afaik
	while true:
		left_index = 2 * index + 1
		right_index = 2 * index + 2
		smallest = index
		
		if left_index < heap.size() and heap[left_index].priority < heap[smallest].priority:
			#print("left")
			smallest = left_index
		if right_index < heap.size() and heap[right_index].priority < heap[smallest].priority:
			#print("right")
			smallest = right_index
			
		if smallest != index:
			temporary_element = heap[index]
			heap[index] = heap[smallest]
			heap[smallest] = temporary_element	
			index = smallest
		else:
			break		
	return output
