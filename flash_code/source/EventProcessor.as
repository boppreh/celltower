package {
    import com.greensock.easing.Elastic;
    import com.greensock.easing.Strong;
    import com.greensock.TweenMax;
    import flash.display.Sprite;
    import flash.events.Event;

    public class EventProcessor extends Sprite {

        private static const MIN_DISTANCE:Number = 35;
        private static const MAX_DISTANCE:Number = 130;

        private static const BORDER_SIZE:Number = 300;
        private static var TIME_WARP:Boolean = false;
        public static var SPEED:Number = 500;

        private var update:Function;

        public var eventStack:Array;
        public var time:Number;

        public function EventProcessor(eventStack:Array, update:Function):void {
            this.eventStack = eventStack;
            this.time = 0;
            this.update = update;
        }

        public function reset():void {
            this.time = 0;
            for each (var tower:Tower in Tower.all) {
                for each (var call:Call in tower.channels) {
                    tower.removeChild(call);
                }
                tower.channels = [];
            }
        }

        public function play():void {
            for each (var tower:Tower in Tower.all) {
                addChild(tower);
            }

            resume();
        }

        public function resume():void {
            TweenMax.resumeAll();
            addEventListener(Event.ENTER_FRAME, step);
        }

        public function pause():void {
            TweenMax.pauseAll();
            removeEventListener(Event.ENTER_FRAME, step);
        }

        public function nextEvent(e:*=null):void {
            if (eventStack.length == 0)
                return;

            var event:CallEvent = eventStack.pop();
            updateOccupation(event.time - time);
            processEvent(event);
            update();
        }

        private function step(e:Event):void {
            if (!eventStack.length) {
                removeEventListener(Event.ENTER_FRAME, step);
                update();
                return;
            }

            var event:CallEvent;

            var timestep:Number = SPEED / stage.frameRate;
            var nextTime:int = time + timestep;
            while (eventStack.length && nextTime >= eventStack[eventStack.length - 1].time) {
                processEvent(eventStack.pop());
            }
            time = nextTime;

            updateOccupation(timestep);
            update();
        }

        private function updateOccupation(timestep:int):void {
            var occupation:int = 0;
            for each (var tower:Tower in Tower.all) {
                occupation += tower.channels.length;
            }

            Tower.minOccupation = Math.min(Tower.minOccupation, occupation);
            Tower.maxOccupation = Math.max(Tower.maxOccupation, occupation);
            Tower.totalOccupation += timestep * occupation;
        }

        private function processEvent(event:CallEvent):void {
            time = event.time;

            var call:Call = event.call;
            switch(event.type) {

                case CallEvent.START_CALL:
                    addChild(call);
                    call.placeAround(call.tower, MIN_DISTANCE, MAX_DISTANCE);

                    call.tower.totalCalls++;

                    if (!transferCall(call, call.tower))
                        return;

                    updateCallDuration(call);

                    TweenMax.from(call, 0.3, { alpha: 0 } );

                    if (call.tower2) {
                        TweenMax.to(call,
                                     call.duration / SPEED,
                                     { x: call.tower2.x + call.circlingDistance * Math.cos(call.circlingAngle),
                                       y: call.tower2.y + call.circlingDistance * Math.sin(call.circlingAngle),
                                       ease: Strong.easeInOut,
                                       overwrite: false } );
                    } else {
                        call.circle(call.tower);
                    }
                    break;

                case CallEvent.END_CALL:
                    if (call.failed)
                        return;

                    updateCallDuration(call);
                    call.activeTower.completedCalls++;
                    call.activeTower.removeCall(call);
                    TweenMax.to(call, 0.3, { alpha: 0, onComplete: removeChild, onCompleteParams: [call] } );
                    break;

                case CallEvent.TOWER_CHANGE:
                    if (call.failed)
                        return;

                    call.tower.removeCall(call);
                    transferCall(call, call.tower2);
                    break;
            }
        }

        private function updateCallDuration(call:Call):void {
            Tower.totalDuration += call.duration / 120;
            Tower.minDuration = Math.min(Tower.minDuration, call.duration / 60);
            Tower.maxDuration = Math.max(Tower.maxDuration, call.duration / 60);
        }

        private function transferCall(call:Call, tower:Tower):Boolean {
            if (tower.addCall(call))
                return true;

            tower.lostCalls++;

            call.failConnection(tower);
            TweenMax.to(call, 1.0, { alpha: 0, onComplete: removeChild, onCompleteParams: [call] } );
            return false;
        }
    }

}