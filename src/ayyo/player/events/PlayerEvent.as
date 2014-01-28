package ayyo.player.events {
	import flash.events.Event;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class PlayerEvent extends Event {
		public static const CAN_LOAD : String = "videoCanBeloaded";
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
