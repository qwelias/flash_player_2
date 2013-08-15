package player.events {
	import flash.events.Event;
	
	public class VolumeChangeEvent extends Event{
		
		public static const VOLUME_CHANGE:String = "volume_change";
		private var _volume:Number;

		public function VolumeChangeEvent(type:String, volume:Number, bubbles:Boolean = false) {
			super(type, bubbles);
			_volume = volume;
		}
		
		public function get volume():Number{
			return _volume;
		}

	}
	
}
