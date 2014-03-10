package ayyo.player.plugins.subtitles.impl {
	import ayyo.player.plugins.subtitles.api.ISubtitlesConfigItem;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class SubtitlesConfigItem implements ISubtitlesConfigItem {
		/**
		 * @private
		 */
		private var _id : String;
		/**
		 * @private
		 */
		private var _name : String;
		/**
		 * @private
		 */
		private var _url : String;

		public function SubtitlesConfigItem(source : Object) {
			this.initialize(source);
		}

		public function get id() : String {
			return this._id;
		}

		public function get name() : String {
			return this._name;
		}

		public function get url() : String {
			return this._url;
		}
		
		public function toString() : String {
			return "[SubtitlesConfigItem] id:" + this.id + ", name:" + this.name + ", url:" + this.url;
		}

		private function initialize(source : Object) : void {
			for (var property : String in source) {
				if (property in this) this["_" + property] = source[property];
			}
		}
	}
}
