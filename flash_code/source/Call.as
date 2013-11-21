package {
    import flash.display.Sprite;
    import flash.events.Event;

    public class Call extends Sprite {

        public static var nextId:int = 1;
        private static const MAX_CIRCLING_SPEED:Number = 0.03;

        public var id:int;
        public var duration:Number;
        public var tower:Tower;
        public var tower2:Tower;
        public var failed:Boolean;

        public var circlingSpeed:Number;
        public var circlingDistance:Number;
        public var activeTower:Tower;

        public function Call(duration:Number, tower:Tower, tower2:Tower) {
            this.id = nextId++;
            this.duration = duration;
            this.tower = tower;
            this.tower2 = tower2;
        }

        public function failConnection(tower:Tower):void {
            setActiveTower(tower);
            failed = true;
        }

        public function setActiveTower(tower:Tower):void {
            if (tower)
                addEventListener(Event.ENTER_FRAME, update);
            else
                removeEventListener(Event.ENTER_FRAME, update);

            activeTower = tower;
        }

        private function update(e:Event):void {
            if (circlingSpeed)
                updateCircleMovement();

            graphics.clear();
            if (failed)
                graphics.lineStyle(4, 0xFF0000, 0.3);
            else
                graphics.lineStyle(4, 0x00FF00, 0.3);

            graphics.lineTo(activeTower.x - this.x, activeTower.y - this.y);
        }

        public function placeAround(tower:Tower, minDistance:Number, maxDistance:Number):void {
            circlingDistance = Math.random() * (maxDistance / 2 - minDistance) + minDistance;
            var angle:Number = Math.random() * Math.PI * 2;
            this.x = tower.x + circlingDistance * Math.cos(angle);
            this.y = tower.y + circlingDistance * Math.sin(angle);
        }

        public function circle(tower:Tower):void {
            circlingSpeed = Math.random() * MAX_CIRCLING_SPEED * 2 - MAX_CIRCLING_SPEED;
        }

        private function updateCircleMovement():void {
            x = circlingDistance * Math.cos(circlingAngle + circlingSpeed) + tower.x;
            y = circlingDistance * Math.sin(circlingAngle + circlingSpeed) + tower.y;
        }

        public function get circlingAngle():Number {
            var distX:Number = this.x - tower.x;
            var distY:Number = this.y - tower.y;
            return Math.atan2(distY, distX);
        }
    }

}