import random

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

class Tower(object):
	all = []

	total_duration = 0
	min_duration = 0
	max_duration = 0

	total_occupation = 0
	min_occupation = 0
	max_occupation = 0

	def __init__(self):
		self.neighbors = []
		self.channels = []
		
		self.max_channels = 0

		self.total_calls = 0
		self.lost_calls = 0
		self.completed_calls = 0

def make_events():
	events = []
	max_calls = 1000
	max_duration = 500
	min_duration = 100
	mean_interval = 10
	interval_range = 5
	chance_tower_change = 0.5

	time = 0

	for i in range(max_calls):
		random_duration = min_duration + random.random() * (max_duration - min_duration)
		random_selected_tower = random.choice(Tower.all)
		random_distance = random.random() * (interval_range * 2) - interval_range + mean_interval
		changed = random.random() < chance_tower_change
		tower2 = None

		if changed:
			tower2 = random.choice(random_selected_tower.neighbors)

		call = Call(random_duration, random_selected_tower, tower2)

		events.append(CallEvent(call, time, CallEvent.START_CALL))
		events.append(CallEvent(call, time + random_duration, CallEvent.END_CALL))

		if changed:
			events.append(CallEvent(call, time + random_duration / 2, CallEvent.TOWER_CHANGE))

		time += random_distance

	events.sort(key=lambda e: e.timelist.)

	return events