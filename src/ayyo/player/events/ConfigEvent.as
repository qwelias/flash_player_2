package ayyo.player.events {
	import flash.events.Event;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class ConfigEvent extends Event {
		public static const PARSED : String = "configParsed";
		/**
		 * @private
		 */
		private var _config : Object;

		public function ConfigEvent(type : String, config : Object = null) {
			super(type, false, false);
			this._config = config;
		}

		public function get config() : Object {
			return this._config;
		}
	}
}
