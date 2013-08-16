package ayyo.player.modules.info.impl {
	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class ModuleInfo {
		/**
		 * @private
		 */
		private var _name : String;

		public function get name() : String {
			return this._name;
		}

		public function set name(value : String) : void {
			if (this._name != value) this._name = value;
		}
	}
}
