package ayyo.player.config.impl.support {
	import ayyo.player.config.api.IReplaceWordList;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class ReplaceWordList implements IReplaceWordList {
		/**
		 * @private
		 */
		private var _forTimeLeft : String;

		public function get forTimeLeft() : String {
			return this._forTimeLeft ||= "%HOURS%";
		}

		public function initialize(source : Object) : void {
			for (var property : String in source) {
				if (property in this) this["_" + property] = source[property];
			}
		}
	}
}
