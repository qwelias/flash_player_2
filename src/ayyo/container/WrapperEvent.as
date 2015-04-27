package ayyo.container
{
	import flash.events.Event;
	
	public class WrapperEvent extends Event
	{
		public static const PLAYABLE:String = "ayyoReadyToPlay";
		public static const PLAY:String = "ayyoDoPlay";
		public static const PAUSE:String = "ayyoDoPause";
		
		private var _params:Array;
		
		public function WrapperEvent(type:String, params:Array = null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this._params = params;
		}
		
		public function get params():Array
		{
			return this._params;
		}
	}
}