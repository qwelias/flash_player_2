package ayyo.player.asstes.info.impl {
	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class AssetInfo {
		/**
		 * @private
		 */
		private var _name : String;
		/**
		 * @private
		 */
		private var _url : String;
		/**
		 * @private
		 */
		private var _type : String;

		public function AssetInfo(source : Object) {
			for (var property : String in source) {
				if (property in this) this["_" + property] = source[property];
			}
		}

		public function get name() : String {
			return this._name;
		}

		public function set name(value : String) : void {
			if (this._name != value) this._name = value;
		}

		public function get type() : String {
			return this._type;
		}

		public function set type(value : String) : void {
			if (this._type != value) this._type = value;
		}

		public function get url() : String {
			return this._url;
		}

		public function set url(value : String) : void {
			if (this._url != value) this._url = value;
		}
	}
}
