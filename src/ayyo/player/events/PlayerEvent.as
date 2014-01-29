package ayyo.player.events {
	import flash.events.Event;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class PlayerEvent extends Event {
		public static const CAN_LOAD : String = "videoCanBeloaded";
		public static const SPLASH_LOADED : String = "splashLoaded";
		public static const ALTERNATIVE_AUDIO : String = "alternativeAudio";
		public static const CAN_PLAY : String = "videoCanPlay";
		/**
		 * @private
		 */
		private var _params : Array;

		public function PlayerEvent(type : String, parameters : Array = null, bubbles : Boolean = false, cancelable : Boolean = false) {
			super(type, bubbles, cancelable);
			this._params = parameters;
		}

		public function get params() : Array {
			return this._params;
		}
	}
}
