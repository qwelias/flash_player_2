package player.events {
	import flash.events.Event;
	
	public class PlayButtonEvent extends Event
	{
		
		public static const PLAYED_CHANGE:String = "played_change";
		private var _played:Boolean;
		
		public function PlayButtonEvent(type:String, played:Boolean, bubbles:Boolean = false)
		{
			super(type, bubbles);
			_played = played;
		}
		
		public function get played():Boolean
		{
			return _played;
		}

	}
	
}
