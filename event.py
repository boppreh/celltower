import random
import math
import sys

if len(sys.argv) < 6:
    print('Needs at least 5 parameters:')
    print('max_channels, call_max_duration, max_interval, change_chance and drop_chance')
    exit()
    
MAX_CHANNELS = sys.argv[1]
CALL_MAX_DURATION = sys.argv[2]
MAX_INTERVAL = sys.argv[3]
CHANGE_CHANCE = sys.argv[4]
DROP_CHANCE = sys.argv[5]

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

    def fail_connection(self, tower):
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
    min_duration = float('inf')
    max_duration = 0

    total_occupation = 0
    min_occupation = float('inf')
    max_occupation = 0

    def __init__(self):
        self.neighbors = []
        self.channels = []
        
        self.max_channels = MAX_CHANNELS

        self.total_calls = 0
        self.lost_calls = 0
        self.completed_calls = 0

    def add_neighbors(self, *towers):
        self.neighbors.extend(towers)

    def add_call(self, call):
        if len(self.channels) >= self.max_channels:
            return False

        self.channels.append(call)
        call.active_tower = self
        return True

    def remove_call(self, call):
        if not call in self.channels:
            return

        self.channels.remove(call)
        call.active_tower = None
        
    def generate_events(self, num_calls, events):
        time = 0

        for i in range(num_calls):
            duration = self.duration_distribution() * 60
            tower2 = None

            chance = random.random() * 100
            if chance < DROP_CHANCE:
                self.tower2 = self.neighbors[1]
            elif chance < DROP_CHANCE + CHANGE_CHANCE:
                self.tower2 = self.neighbors[0]

            call = Call(duration, self, tower2)
            events.append(CallEvent(call, time, CallEvent.START_CALL))
            if call.tower2:
                events.append(CallEvent(call, time + call.duration / 2, CallEvent.TOWER_CHANGE))
            events.append(CallEvent(call, time + call.duration, CallEvent.END_CALL))
            time += self.interval_distribution()

    def interval_distribution(self):
        return -math.log(random.random()) * MAX_INTERVAL

    def duration_distribution(self):
        return -math.log(random.random()) * CALL_MAX_DURATION

class EventProcessor(object):
    def __init__(self, events, towers):
        self.events = events
        self.time = 0
        self.towers = towers

    def next_event(self):
        if not self.events:
            raise Exception

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

        if event.type_ == CallEvent.START_CALL:
            call.tower.total_calls += 1

            if not self.transfer_call(call, call.tower):
                return

            self.update_call_duration(call)

        elif event.type_ == CallEvent.END_CALL:
            if call.failed:
                return

            self.update_call_duration(call)
            call.active_tower.completed_calls += 1
            call.active_tower.remove_call(call)
            
        elif event.type_ == CallEvent.TOWER_CHANGE:
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
    t1 = Tower()
    t2 = Tower()
    t3 = Tower()
    Tower.all = [t1, t2, t3]
    t1.add_neighbors(t2, t3);
    t2.add_neighbors(t1, t3);
    t3.add_neighbors(t1, t2);

    events = []
    t1.generate_events(1000 // 2, events)
    t2.generate_events(1000 // 2, events)
    events.sort(key=lambda e: e.time)

    processor = EventProcessor(events, Tower.all)
    while events:
        processor.next_event()

    total_calls = t1.total_calls + t2.total_calls
    def stat(partial_calls):
        return '{} ({}%)'.format(partial_calls, int(partial_calls * 100 / total_calls))

    print('Total calls:', t1.total_calls + t2.total_calls)
    print('Completed calls:', stat(t1.completed_calls + t2.completed_calls))
    print('Lost calls:', stat(t1.lost_calls + t2.lost_calls))
    print('Left calls:', stat(t3.lost_calls))
    print()
    print('Min duration:', int(Tower.min_duration), 'min')
    print('Mean duration:', int(Tower.total_duration / total_calls), 'min')
    print('Max duration:', int(Tower.max_duration), 'min')
    print()
    print('Min occupation:', int(Tower.min_duration), 'min')
    print('Mean occupation:', int(Tower.total_duration / total_calls), 'min')
    print('Max occupation:', int(Tower.max_duration), 'min')