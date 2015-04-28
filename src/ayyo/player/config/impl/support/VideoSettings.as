package ayyo.player.config.impl.support {
	import ayyo.player.config.api.IAyyoVideoSettings;

	import flash.external.ExternalInterface;
	import flash.system.Capabilities;

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
			return "type=online," + this._token + ",os=" + escape(Capabilities.os) +",flashversion=" + escape(Capabilities.version) + ",browser=" + "unknown";
		}

		public function initialize(source : Object) : void {
			for (var property : String in source) {
				if (property in this) this["_" + property] = source[property];
			}
		}
	}
}
