package ayyo.player.events {
	import flash.events.Event;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class PlayerEvent extends Event {
		public static const CAN_LOAD : String = "videoCanBeloaded";
		public static const SPLASH_LOADED : String = "splashLoaded";
		public static const ALTERNATIVE_AUDIO : String = "alternativeAudio";
		public static const AUDIO : String = "audioTrait";
		public static const CAN_PLAY : String = "playTrait";
		public static const TIME_TRAIT : String = "timeTrait";
		public static const BUFFER_TRAIT : String = "bufferTrait";
		public static const DYNAMIC_STREAM_TRAIT : String = "dynamicStreamTrait";
		public static const SHOW_PRELOADER : String = "showPreloader";
		public static const HIDE_PRELOADER : String = "hidePreloader";
		public static const DYNAMIC_STREAM_CHANGE : String = "dynamicStreamChange";
		public static const MEDIA_CHANGED : String = "mediaChanged";
		public static const PLAYBACK_COMPLETE : String = "playbackComplete";
		public static const SEND_TO_JS : String = "sendParamsToJS";
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
