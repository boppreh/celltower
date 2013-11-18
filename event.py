import random
import math

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
        
        self.max_channels = 10

        self.total_calls = 0
        self.lost_calls = 0
        self.completed_calls = 0

    def add_neighbors(self, *towers):
        self.neighbors.extend(tower)

    def add_call(self, call):
        if self.channels >= self.max_channels:
            return False

        channels.append(call)
        call.active_tower = self
        return True

    def remove_call(self, call):
        if not call in self.channels:
            return

        self.channels.remove(call)
        call.active_tower = None
        
    def generate_events(num_calls, events):
        time = 0

        for i in range(num_calls):
            duration = self.duration_distribution() * 60
            tower2 = None

            chance = random.random() * 100
            if chance < self.num_drop:
                self.tower2 = self.neighbors[1]
            elif chance < self.num_drop + self.num_change:
                self.tower2 = self.neighbors[0]

            call = Call(duration, self, tower2)
            events.append(CallEvent(call, time, CallEvent.START_CALL))
            if self.tower2:
                events.append(CallEvent(call, time + call.duration / 2, CallEvent.TOWER_CHANGE))
            events.append(CallEvent(call, time + call.duration, CallEvent.END_CALL))
            time += self.interval_distribution()

    def interval_distribution(self):
        return -math.log(random.random()) * Tower.num_interval

    def duration_distribution(self):
        return -math.log(random.random()) * 25

class EventProcessor(object):
    def __init__(self, events):
        self.events = events
        self.time = 0

    def next_event(self):
        if not self.events:
            return

        event = self.events.pop(0)
        self.update_occupation(event.time - self.time)
        self.process_event(event)

    def update_occupation(self, timestep):
        occupation = 0
        for tower in self.towers:
            occupation += len(tower.channels)

        Tower.min_occupation = min(Tower.min_occupation, occupation)
        Tower.max_occupation = min(Tower.max_occupation, occupation)
        Tower.total_occupation += timestep * occupation

    def process_event(self, event):
        time = event.time
        call = event.call

        if event.type == CallEvent.START_CALL:
            call.tower.total_calls += 1

            if not self.transfer_call(call, call.tower):
                return

            self.update_call_duration(call)

        elif event.type == CallEvent.END_CALL:
            if call.failed:
                return

            self.update_call_duration(call)
            call.active_tower.completed_calls += 1
            call.active_tower.remove_call(call)
            
        elif event.type == CallEvent.TOWER_CHANGE:
            if call.failed:
                return

            call.tower.remove_call(call)
            self.transfer(call, call.tower2)

    def update_call_duration(self, call):
        Tower.total_duration += call.duration / 120
        Tower.min_duration = min(Tower.min_duration, call.duration / 60)
        Tower.max_duration = max(Tower.max_duration, call.duration / 60)

    def transfer_call(self, call, tower):
        if tower.add_call(call):
            return True

        tower.lost_calls += 1

        call.fail_connection(tower)
        return False

if __name__ == '__main__':
    pass