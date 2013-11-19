import subprocess
import re
from itertools import product

def run(max_channels, call_max_duration, max_interval, change_chance, drop_chance):
    args = list(map(str, [max_channels, call_max_duration, max_interval, change_chance, drop_chance]))
    process = subprocess.Popen(['python3', 'event.py'] + args, stdout=subprocess.PIPE)
    output = process.communicate()[0].decode('utf-8')
    return float(re.search(r'Lost calls: \d+ \((\d+)%\)', output).groups()[0])

test_values = [[10, 25, 50], [1, 5, 20], [1, 5, 20], [0, 0.2, 0.4], [0, 0.2, 0.4]]
with open('results.csv', 'w') as output:
    output.write('max_channels,call_max_duration,max_interval,change_chance,drop_chance,calls_dropped\n')
    for args in product(*test_values):
        result = run(*args)
        output.write(','.join(map(str, args + (result,))) + '\n')
        print(args, result)