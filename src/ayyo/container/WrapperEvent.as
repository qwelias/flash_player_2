package ayyo.container
{
	import flash.events.Event;
	
	public class WrapperEvent extends Event
	{
		public static const BEFORE_LOAD:String = "ayyoReadyToLoad";
		public static const LOAD:String = "ayyoPlzLoad";
		public static const PLAYABLE:String = "ayyoReadyToPlay";
		public static const PLAY:String = "ayyoDoPlay";
		public static const PAUSE:String = "ayyoDoPause";
		public static const VOLUME:String = "ayyoTweakVolume";
		public static const ERROR:String = "ayyoError";
		public static const STAGE:String = "stageVideosPassed";
//		public static const DURATION:String = "ayyoDuration";
		
		
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