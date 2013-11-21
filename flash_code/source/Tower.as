package {
    import com.gskinner.utils.Rndm;
    import flash.display.DisplayObject;
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.events.Event;

    public class Tower extends Sprite {

        public static var all:Array;

        public static var totalDuration:Number;
        public static var minDuration:Number;
        public static var maxDuration:Number;

        public static var totalOccupation:Number;
        public static var minOccupation:int;
        public static var maxOccupation:int;

        public var channels:Array;
        public var maxChannels:int;
        public var neighbors:Array;

        public var totalCalls:int = 0;
        public var lostCalls:int = 0;
        public var completedCalls:int = 0;

        public function Tower() {
            neighbors = [];
            channels = [];
            graphics.lineStyle(2, 0x00F00, 0.3, true);
        }

        public function generateEvents(config:MovieClip, numCalls:int, eventsArray:Array):void {
            maxChannels = config.numChannels.value;

            var durationDistribution:Function = getDurationDistributionFunction(config);
            var intervalDistribution:Function = getIntervalDistributionFunction(config);

            var time:Number = 0;
            while (numCalls--) {
                var duration:Number = durationDistribution() * 60;
                var tower2:Tower = null;

                var chance:Number = Rndm.random() * 100;
                if (chance < config.numDrop.value) {
                    tower2 = neighbors[1];
                } else if (chance < config.numDrop.value + config.numChange.value) {
                    tower2 = neighbors[0];
                }

                var call:Call = new Call(duration, this, tower2);
                eventsArray.push(new CallEvent(call, time, CallEvent.START_CALL));
                if (tower2)
                    eventsArray.push(new CallEvent(call, time + call.duration / 2, CallEvent.TOWER_CHANGE));
                eventsArray.push(new CallEvent(call, time + call.duration, CallEvent.END_CALL));

                time += intervalDistribution();
            }
        }

        private function getIntervalDistributionFunction(config:MovieClip):Function {
            return function():Number {
                return -Math.log(Rndm.random()) * config.numInterval.value;
            };
        }

        private function getDurationDistributionFunction(config:MovieClip):Function {
            if (config.radExpo.selected) {
                return function():Number {
                    return -Math.log(Rndm.random()) * config.numExpo1.value;
                }
            } else if (config.radUniform.selected) {
                return function():Number {
                    return config.numUniform1.value + (config.numUniform2.value - config.numUniform1.value) * Rndm.random();
                }
            } else if (config.radConstant.selected) {
                return function():Number {
                    return config.numConstant.value;
                }
            } else if (config.radTriangular.selected) {
                return function():Number {
                    var a:Number = config.numTriangular1.value;
                    var b:Number = config.numTriangular2.value;
                    var c:Number = config.numTriangular3.value;
                    var random:Number = Rndm.random();
                    var fc:Number = (c - a) / (b - a);
                    if (random < fc) {
                        return a + Math.sqrt(random * (b - a) * (c - a));
                    } else {
                        return b - Math.sqrt((1 - random) * (b - a) * (b - c));
                    }
                }
            } else if (config.radNormal.selected) {
                return function():Number {
                    var u:Number = Rndm.random();
                    var v:Number = Rndm.random();
                    var r:Number = Math.sqrt( -2 * Math.log(u)) * Math.cos(2 * Math.PI * v);
                    return r / Math.sqrt(config.numNormal2.value) + config.numNormal1.value;
                }
            }

            return null;
        }

        public function addNeighbors(...towers:Array):void {
            neighbors = neighbors.concat(towers);
        }

        public function addCall(call:Call):Boolean {
            if (channels.length < maxChannels) {
                channels.push(call);
                call.setActiveTower(this);
                return true;
            } else {
                return false;
            }
        }

        public function removeCall(call:Call):void {
            if (channels.indexOf(call) == -1)
                return;

            channels.splice(channels.indexOf(call), 1);
            call.setActiveTower(null);
        }
    }

}