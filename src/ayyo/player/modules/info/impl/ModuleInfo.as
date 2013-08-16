package ayyo.player.modules.info.impl {
	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class ModuleInfo {
		/**
		 * @private
		 */
		private var _name : String;
		/**
		 * @private
		 */
		private var _config : String;

		public function get name() : String {
			return this._name;
		}

		public function set name(value : String) : void {
			if (this._name != value) this._name = value;
		}

		public function get config() : String {
			return this._config;
		}

		public function set config(value : String) : void {
			if (this._config != value) this._config = value;
		}
	}
}
