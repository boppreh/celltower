class Call(object):
	nextId = 1

	def __init__(self, duration, tower, tower2):
		self.id = Call.nextId
		Call.nextId += 1

		self.duration = duration
		self.tower = tower
		self.tower2 = tower2
		self.failed = False
		self.active_tower = None

	def fail_connection(tower):
		self.failed = True
		self.active_tower = tower

class CallEvent(object):
	START_CALL = 0
	END_CALL = 1
	TOWER_CHANGE = 2

	def __init__(self, call, time, type_):
		self.call = call
		self.time = time
		self.type_ = type_