package ayyo.player.config.impl {
	import ayyo.player.config.api.ICanInitialize;
	import ayyo.player.config.api.IPlayerAsset;
	import ayyo.player.config.api.IPlayerConfig;
	import ayyo.player.config.api.IPlayerSettings;
	import ayyo.player.config.api.IReplaceWordList;
	import ayyo.player.config.impl.support.PlayerSettings;
	import ayyo.player.config.impl.support.PlayerTooltip;
	import ayyo.player.config.impl.support.ReplaceWordList;
	import ayyo.player.tooltip.api.IPlayerTooltip;

	/**
	 * @author Aziz Zaynutdinov (actionsmile at icloud.com)
	 */
	public class JSONPlayerConfig implements IPlayerConfig {
		/**
		 * @private
		 */
		private var _settings : IPlayerSettings;
		/**
		 * @private
		 */
		private var _assets : Vector.<IPlayerAsset>;
		/**
		 * @private
		 */
		private var _tooltip : IPlayerTooltip;
		/**
		 * @private
		 */
		private var _replaceWord : ReplaceWordList;

		public function initialize(source : Object) : void {
			var item : ICanInitialize;
			for (var property : String in source) {
				if (property in this) item = this[property] as ICanInitialize;
				item && item.initialize(source[property]);
			}
		}

		public function get settings() : IPlayerSettings {
			return this._settings ||= new PlayerSettings();
		}

		public function get assets() : Vector.<IPlayerAsset> {
			return this._assets ||= new Vector.<IPlayerAsset>();
		}

		public function get tooltip() : IPlayerTooltip {
			return this._tooltip ||= new PlayerTooltip();
		}

		public function get replaceWord() : IReplaceWordList {
			return this._replaceWord ||= new ReplaceWordList;
		}
	}
}
