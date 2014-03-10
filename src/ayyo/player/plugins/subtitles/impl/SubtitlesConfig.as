package ayyo.player.plugins.subtitles.impl {
	import ayyo.player.plugins.subtitles.api.ISubtitlesConfigItem;

	import flash.utils.Dictionary;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class SubtitlesConfig {
		/**
		 * @private
		 */
		private var _configurations : Dictionary;
		/**
		 * @private
		 */
		private var _length : uint;

		public function SubtitlesConfig(configSource : Object) {
			this.initialize(configSource);
		}

		public function initialize(source : Object) : void {
			if (source is Array) {
				this.addElementsFromArray(source as Array);
			} else {
				this.addElementsFromArray([source]);
			}
		}

		public function getConfigByID(configID : String) : ISubtitlesConfigItem {
			return this.configurations[configID];
		}

		public function get configurations() : Dictionary {
			return this._configurations ||= new Dictionary();
		}

		public function get length() : uint {
			return this._length;
		}

		public function set length(value : uint) : void {
			this._length = value;
		}

		private function addElementsFromArray(array : Array) : void {
			var item : ISubtitlesConfigItem;
			while (array.length) {
				item = new SubtitlesConfigItem(array.pop());
				this.configurations[item.id] = item;
				this.length++;
			}
		}
	}
}
