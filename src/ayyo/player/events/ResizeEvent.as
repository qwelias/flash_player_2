package ayyo.player.events {
	import flash.events.Event;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class ResizeEvent extends Event {
		public static const RESIZE : String = "applicationStageReszied";
		/**
		 * @private
		 */
		private var _newWidth : int;
		/**
		 * @private
		 */
		private var _newHeight : int;

		public function ResizeEvent(type : String, newWidth : int, newHeight : int) {
			super(type, false, false);
			this._newWidth = newWidth;
			this._newHeight = newHeight;
		}

		public function get newWidth() : int {
			return this._newWidth;
		}

		public function get newHeight() : int {
			return this._newHeight;
		}
	}
}
