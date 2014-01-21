package ayyo.player.config.impl.support {
	import ayyo.player.config.api.IAyyoVideoSettings;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class VideoSettings implements IAyyoVideoSettings {
		/**
		 * @private
		 */
		private var _url : String;
		/**
		 * @private
		 */
		private var _token : String;

		public function get url() : String {
			return this._url;
		}

		public function get token() : String {
			return this._token;
		}

		public function initialize(source : Object) : void {
			for (var property : String in source) {
				if (property in this) this["_" + property] = source[property];
			}
		}
	}
}
