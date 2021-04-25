extends RigidBody2D

func set_connected(node):
	$Pin.set_node_a(self.get_path())
	$Pin.set_node_b(node.get_path())

func break_joint():
	$Pin.set_node_a("")
	$Pin.set_node_b("")
