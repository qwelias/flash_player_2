package ayyo.player.config.impl.support {
	import ayyo.player.config.api.IReplaceWordList;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class ReplaceWordList implements IReplaceWordList {
		/**
		 * @private
		 */
		private var _timeLeft : String;

		public function get timeLeft() : String {
			return this._timeLeft ||= "%HOURS%";
		}

		public function initialize(source : Object) : void {
			for (var property : String in source) {
				if (property in this) this["_" + property] = source[property];
			}
		}
	}
}
