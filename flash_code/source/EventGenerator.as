package {
    import flash.display.MovieClip;

    public class EventGenerator {
        public static function makeEventStack():Array {
            var eventStack:Array = [];
            var maxCalls:int = 1000;
            var maxDuration:Number = 500;
            var minDuration:Number = 100;
            var meanInterval:Number = 10;
            var intervalRange:Number = 5;
            var chanceTowerChange:Number = 0.5;

            var time:Number = 0;

            while (maxCalls--) {
                var randomDuration:Number = minDuration + Math.random() *  (maxDuration - minDuration);
                var randomSelectedTower:Tower = Tower.all[int(Math.random() * Tower.all.length)];
                var randomDistance:Number = (Math.random() * (intervalRange * 2) - intervalRange) + meanInterval;
                var changed:Boolean = Math.random() < chanceTowerChange;
                var tower2:Tower = null;

                if (changed) {
                    tower2 = randomSelectedTower.neighbors[int(Math.random() * randomSelectedTower.neighbors.length)];
                }

                var call:Call = new Call(randomDuration, randomSelectedTower, tower2);

                var startEvent:CallEvent = new CallEvent(call, time, CallEvent.START_CALL);
                var endEvent:CallEvent = new CallEvent(call, time + randomDuration, CallEvent.END_CALL);
                eventStack.push(startEvent);
                eventStack.push(endEvent);

                if (changed) {
                    var changeEvent:CallEvent = new CallEvent(call, time + randomDuration / 2, CallEvent.TOWER_CHANGE);
                    eventStack.push(changeEvent);
                }

                time += randomDistance;
            }

            eventStack.sortOn("time", Array.NUMERIC | Array.DESCENDING);

            return eventStack;
        }
    }

}