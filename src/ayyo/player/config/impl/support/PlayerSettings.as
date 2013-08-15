package ayyo.player.config.impl.support {
	import ayyo.player.config.api.IPlayerSettings;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class PlayerSettings implements IPlayerSettings {
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

		public function initialize(source : Object) : void {
			for (var property : String in source) {
				if(property in this) this["_" + property] = source[property];
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
	}
}
