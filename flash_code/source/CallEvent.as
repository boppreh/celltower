package {

    public class CallEvent {

        public static const START_CALL:uint = 0;
        public static const END_CALL:uint = 1;
        public static const TOWER_CHANGE:uint = 2;

        public var type:uint;
        public var call:Call;
        public var time:Number;

        public function CallEvent(call:Call, time:Number, type:uint) {
            this.call = call;
            this.time = time;
            this.type = type;
        }
    }

}