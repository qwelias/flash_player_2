package ayyo.player.config.impl.support {
	import ayyo.player.config.api.IAyyoPlayerSettings;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class PlayerSettings implements IAyyoPlayerSettings {
		/**
		 * @private
		 */
		private var _screenshot : String;
		/**
		 * @private
		 */
		private var _type : String;
		/**
		 * @private
		 */
		private var _free : Boolean;
		/**
		 * @private
		 */
		private var _timeLeft : Number;
		/**
		 * @private
		 */
		private var _baseURL : String;
		/**
		 * @private
		 */
		private var _autoplay : Boolean;
		/**
		 * @private
		 */
		private var _buffer : Number;

		public function initialize(source : Object) : void {
			for (var property : String in source) {
				if (property in this) this["_" + property] = source[property];
			}
		}

		public function get screenshot() : String {
			return this._screenshot;
		}

		public function get type() : String {
			return this._type ||= PlayerType.MOVIE;
		}

		public function get free() : Boolean {
			return this._free;
		}

		public function get timeLeft() : Number {
			return this._timeLeft ||= 48;
		}

		public function get baseURL() : String {
			return this._baseURL ||= "";
		}

		public function get autoplay() : Boolean {
			return this._autoplay;
		}

		public function get buffer() : Number {
			return this._buffer;
		}
	}
}
