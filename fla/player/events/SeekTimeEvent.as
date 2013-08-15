package player.events {
	import flash.events.Event;
	
	public class SeekTimeEvent extends Event{
		
		public static const SEEK_TIME_CHANGE:String = "seek_time_change";
		private var _seekTime:Number;

		public function SeekTimeEvent(type:String, seekTime:Number, bubbles:Boolean = false) {
			super(type, bubbles);
			_seekTime = seekTime;
		}
		
		public function get seekTime():Number{
			return _seekTime;
		}

	}
	
}
