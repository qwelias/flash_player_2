package player.events {
	import flash.events.Event;
	
	public class HDButtonEvent extends Event{
		
		public static const HD_BUTTON_TRIGGED:String = "hd_button_trigged";
		private var _hdActive:Boolean;

		public function HDButtonEvent(type:String, hdActive:Boolean, bubbles:Boolean = false) {
			super(type, bubbles);
			_hdActive = hdActive;
		}
		
		public function get hdActive():Boolean{
			return _hdActive;
		}

	}
	
}
