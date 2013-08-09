package player.events
{
	import flash.events.Event;
	
	public class SubtitlesHandledEvent extends Event
	{
		
		public static const LOAD_COMPLETE:String = "load_complete";
		private var _subtitles:Array;
		
		public function SubtitlesHandledEvent(type:String, subtitles:Array, bubbles:Boolean = false):void
		{
			super(type, bubbles);
			_subtitles = subtitles;
		}
		
		public function get subtitles():Array
		{
			return _subtitles;
		}

	}
	
}
