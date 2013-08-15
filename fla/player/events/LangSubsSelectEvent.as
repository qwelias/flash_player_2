package player.events
{
	import flash.events.Event;
	
	public class LangSubsSelectEvent extends Event
	{
		
		public static const LANG_SELECT:String = "lang_select";
		public static const SUBS_TOGGLE:String = "subs_toggle";
		
		public static const LANG:Array = ["rus", "eng"];
		
		private var _val:String;
		
		public function LangSubsSelectEvent(type:String, val:String, bubbles:Boolean = false)
		{
			super(type, bubbles);
			_val = val;
		}
		
		public function get val():String
		{
			return _val;
		}

	}
	
}
